#!/usr/bin/env perl

use lib "../";
use lib "/biobox/lib/";

use strict;
use warnings;
use Data::Dumper;
use Utils;

my @tasks = @{Utils::collectYAMLtasks()};
foreach my $task (@tasks) {
  my $id = $task->{inputfile};
  $id =~ s/ /_/g;
  $id =~ s|/|_|g;

  push @{$task->{commands}}, (
    "sourmash compute --scaled 10000 -k 51 --track-abundance --name-from-first -o ".$task->{resultfilename}.".sig ".$task->{inputfile},
    "sourmash gather --scaled 10000 -k 51 --output ".$task->{resultfilename}.".csv ".$task->{resultfilename}.".sig ".$task->{databaseDir}."/refseq-k51-s10000.lca.json.gz",
    "rm ".$task->{resultfilename}.".sig",
    $ENV{PREFIX}."/bin/convert.py --output ".$task->{resultfilename}.".profile".
    " --taxdump ".$task->{taxonomyDir}.
    " --acc2taxid ".$task->{taxonomyDir}."accession2taxid/nucl_gb.accession2taxid.gz ".
    " --acc2taxid ".$task->{taxonomyDir}."accession2taxid/nucl_wgs.accession2taxid.gz ".
    $id." ".$task->{resultfilename}.".csv",
  );
}

Utils::executeTasks(\@tasks);
