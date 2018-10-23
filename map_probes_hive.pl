#!/bin/env perl
use strict;
use warnings;
use Getopt::Std;
use Bio::EnsEMBL::Registry;

# This script submits hive jobs to map probes to previously loaded gene builds
#
# It uses env $USER to create hive job names and assumes Ensembl-version API
# is loaded in @INC / $PERL5LIB
#
# Adapted from Dan Bolser's run_the_probe_mapping_pipeline.sh by B Contreras Moreira
#
# https://www.ebi.ac.uk/seqdb/confluence/display/ensf/Probemapping
#
## check user arguments ######################################################
##############################################################################

my (%opts,$species_db_name,@species_dbs,$probes_dir,$core_db,$ensembl_version);
my ($pipeline_dir,$reg_file,$hive_args,$hive_db,$hive_url,$argsline);
my $overwrite = 0;
my $hive_db_cmd = 'mysql-eg-hive-ensrw';

getopts('hws:d:R:H:P:v:', \%opts);

if(($opts{'h'})||(scalar(keys(%opts))==0)){
  print "\nusage: $0 [options]\n\n";
  print "-h this message\n";
  print "-s species_db_name or file with one db/line    (required, example: -s arabidopsis_thaliana_funcgen_38_91_11)\n";
  print "-v next Ensembl version                        (required, example: -v 95)\n";
  print "-d probes directory, can be env variable       (required, example: -d \$probedir)\n";
  print "-R registry file, can be env variable          (required, example: -R \$p2panreg)\n";
  print "-P folder to put pipeline files, can be env    (required, example: -P \$probetmp)\n";
  print "-H hive database command                       (optional, default: $hive_db_cmd)\n";
  print "-w over-write db (hive_force_init)             (optional, useful when a previous run failed)\n\n";                             
  exit(0);
}

if($opts{'s'}){ 
	$species_db_name = $opts{'s'};
	if(-e $species_db_name){ # is this a file?
		open(DBLIST,'<',$species_db_name) || 
			die "# ERROR: cannot read $species_db_name\n";
		while(<DBLIST>){
			next if(/^#/);
			push(@species_dbs,(split)[0])
		}
		close(DBLIST);
	}
	else{ push(@species_dbs,$species_db_name) }
} 
else{ die "# EXIT : need a valid -s species_db_name/file, such as -s arabidopsis_thaliana_funcgen_38_91_11\n" }

if($opts{'v'}){
	$ensembl_version = $opts{'v'};	

	# check Ensembl API is in env
	if(!grep(/ensembl-$ensembl_version\/ensembl-hive\/modules/,@INC)){
		die "# EXIT : cannot find ensembl-$ensembl_version/ensembl-hive/modules in \$PERL5LIB / \@INC\n"
	} 
}
else{ die "# EXIT : need a valid -v version, such as -v 95\n" }

if($opts{'d'} && -d $opts{'d'}){ $probes_dir = $opts{'d'} }
else{ die "# EXIT : need a valid -d probes dir, such as -d \$probedir\n" }

if($opts{'R'} && -e $opts{'R'}){ $reg_file = $opts{'R'} }
else{ die "# EXIT : need a valid -R file, such as -R \$p2panreg\n" }

if($opts{'P'} && -d $opts{'P'}){ $pipeline_dir = $opts{'P'} }
else{ die "# EXIT : need a valid -P folder to put pipeline files, such as -P \$gfftmp\n" }

if($opts{'H'}){ $hive_db_cmd = $opts{'H'} }
chomp( $hive_args = `$hive_db_cmd details script` );
chomp( $hive_url  = `$hive_db_cmd --details url` );
$hive_db = $ENV{'USER'}."_probemapping_hive";
$hive_url .= $hive_db;

if($opts{'w'}){ $overwrite = 1 }

$argsline = sprintf("%s -s %s -v %s -d %s -R %s -H %s -P %s -w %d",
	$0, $species_db_name, $ensembl_version, $probes_dir, 
	$reg_file, $hive_db_cmd, $pipeline_dir, 
	$overwrite);

print "# $argsline\n\n";

exit;


## Run init script and produce a hive_db with all tasks to be carried out
#########################################################################

# foreach my $species_db_name {
# 	$core_db = $species_db_name;
#       $core_db =~ s/_funcgen_/_core_/; # this task requires a matching core db to run
#

my $conf="Bio::EnsEMBL::Funcgen::PipeConfig::ProbeMapping";

my $initcmd = "init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::LoadGFF3_conf ".
    	"$hive_args ".
    	"--registry $reg_file ".
    	"--pipeline_dir $pipeline_dir ".
    	"--species $species_db_name ".
	"--hive_force_init $overwrite";

print "# $initcmd\n\n";

#open(INITRUN,"$initcmd |") || die "# ERROR: cannot run $initcmd\n";
#while(<INITRUN>){
#	print;
#}
#close(INITRUN);

## Send jobs to hive 
######################################################################### 

#print "# hive job URL: $hive_url";

#system("beekeeper.pl -url '$hive_url;reconnect_when_lost=1' -sync");
#system("runWorker.pl -url '$hive_url;reconnect_when_lost=1' -reg_conf $reg_file");
#system("beekeeper.pl -url '$hive_url;reconnect_when_lost=1' -reg_conf $reg_file -loop");

#print "# hive job URL: $hive_url\n\n";

