#!/usr/bin/perl -w


our $VERSION='0.20250301';	# Please use format: major_revision.YYYYMMDD[hh24mi]

=head1 git-meta

Easy solution to:

=over 4

=item *

Automatically preserve all the correct dates, times (including zones and microseconds), ownership, and access permissions on all your files in git

=item *

Quickly set up a new non-cloud, non-github private git project on your own servers, which you and/or your team can work with from any number of other machines

=item *

Optionally have your server automatically extract your files and keep them up-to-date (for example: so you can deploy to your webserver's live environment with "git push"

=back



=head1 Quick-Start

=over 4

=item 1

install it:

	git clone https://github.com/gitcnd/git-meta.git
	sudo cp -a git-meta/git-meta.pl /usr/local/bin/

=back

then either


=over 4

=item *

set up to use it:

	cd my_existing_repo
	git-meta.pl -setup -l /usr/local/bin/git-meta.pl

=back

or

=over 4

=item *

create a brand-new local project

	git-meta.pl -newgit -l . MyProject /var/www/html/MyProject-optional-autoextract-folder


=back

=cut

	# don't change it if we wouldn't have permission in the first place?
	# runs in DOS?
	# runs in some non-WSL linux too?

	# shareproject;echo export FN first;echo doing $FN; dir -d ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto; chgrp -R devgrp ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto;chmod ug+rw `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto`;  chmod ug+rwx `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto -type d`; chmod g+s `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto -type d`;sudo setfacl -d -m g::rwx ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto; echo after; dir -d ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto

	# $ git-meta.pl -setup  -group devgrp -autopush 
	# pushd .git/hooks/..; git config --local core.fileMode false;popd
	# sh: 1: pushd: not found
	# sh: 1: popd: not found

	# chown: changing ownership of 'README.txt': Operation not permitted


	# bug: needs chmod -R g+w .
	# if -l option, no chmod needed
	# no follow symlinks
	# needs chown -R before the --local
	# snafu:  drwxr-xr-x. 3 root root 77 Feb 21 21:22 /var/www/html/userfriday/
	# -rw-rw-r--. 1 root user 66 Feb 21 21:22 ../../gitblobs/website_user/config
	# hint: The 'hooks/post-update' hook was ignored because it's not set as executable.

	# shareproject;
	# echo export FN first;
	# echo doing $FN;
	# dir -d ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto;
	# chgrp -R user ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto;
	# chmod ug+rw `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto`;
	# chmod ug+rwx `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto -type d`;
	# chmod g+s `find ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto -type d`;
	# sudo setfacl -d -m g::rwx ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto;
	# echo after;
	# dir -d ~/Downloads/gitblobs/$FN ~/Downloads/cursor/$FN ~/Downloads/cursor/$FN-auto

	# needs ug+rwx as well as +s

	# ?	git config --global --add safe.directory /home/user/Downloads/cursor/cursor_template

	# touch: setting times of '.htaccess': Operation not permitted
	# ^^ don't try to change it if its the same



=head1 Synopsis

=head2 Mode 1 - preserving dates/times/ownership/permissions etc:

	# creates the pre-commit and post-checkout hooks (see below)
	cd ~/myrepo
	git-meta.pl -setup -l /usr/local/bin/git-meta.pl
	-or-
	git-meta.pl -setup


	# optional manual "save" usage (Typically this is called from the pre-commit) to preserve dates/times/ownership/permissions
	cd ~/myrepo
	git-meta.pl -save [optional list of files]


	# optional manual "restore" usage (Typically called from post-checkout)
	cd ~/myrepo
	git-meta.pl -restore [optional list of files]


=head3 How Mode 1 works:

A git pre-commit hook is added, which creates the file ".git-meta" in your project and adds this to your commit.  
.git-meta contains all the real file metadata in your project (correct dates and times, ownerships, permissions, etc)

A git post-checkout hook is added, which restores all the correct information from the .git-meta file



=head2 Mode 2 - Automatically set up a new full-featued non-cloud repo on your own machine/servers

	# Create a new local master repo, which preserves dates etc, and also automatically extracts files every time you push (handy for automatically deploying to a live web server through git-push for example)
	# (handy for working on your own private mahcines, such as when maintaining web servers.)
	perl git-meta.pl -master_location=/usr/local/apache2/gitblobs -newgit mynewproject /usr/local/apache2/htdocs/mynewproject

	# creates a working 3-folder shared dev environment for production web server site
	# Omitting "-master_location" will default to ~/gitblobs
	# Uses `sudo chmod g+s` to allow for multi-user environemnts based on unix group permissions.

Note: adds the file .git-meta to your project


=head3 How Mode 2 works:

Run git-meta.pl with the -newgit option on your server (e.g. your web server) where your master files will live.  e.g.

	perl git-meta.pl -newgit MyProject /var/www/html/MyProject

A "master" folder where all your master files will live is created locally on that server, by default this will be in ~/gitblobs/MyProject
A "working" folder where you check out and edit your files etc is create locally too: e.g. the example folder will be: ./MyProject
An optional "live" folder is also created - this is where all your most up-to-date copies of your files will be auto-extracted into (e.g. typically your webroot folder, like /var/www/html/MyProject/ )
Permissions etc are correctly set up for teams to work on these files (see also the -group option)
The "git-meta.pl -setup" option is applied locally too, so all your file dates/etc will be properly preserved at all times

You can then clone additional copies of the above onto other machines - e.g. your laptop, like this:

	git clone ssh://your-server/home/username/gitblobs/MyProject
	cd MyProject
	git-meta.pl -setup -l . 

be sure to run that `git-meta.pl -setup -l .` command: "git clone" does not automatically clone the hooks you need which are required to keep your dates/times/etc preserved.


=head2 Options

	-f <file>	# Specify the meta filename to use ( defaults to .git-meta )
	-save		# Save into the .git-meta. Saves all files if none are provided
	-restore	# Restore from the .git-meta. Restores all files if none are provided
	-setup		# create the necessary pre-commit and post-checkout files to activate this solution in your repo
	-strict		# Stop with errors instead of assume what the user wants (partially implimented)
	-dryrun		# Show what would be done, without doing it (partially implimented)
	-l <target>	# use a symlink when doing setup, for pre-commit and post-checkout (e.g. -l /usr/local/bin/git-meta.pl) - otherwise - copies the file there. ** Do NOT use -l if Windows uses your filesystem (eg, WSL, or Windows itself) **
	-c <folder>	# "cd" into this folder first
	-newgit		# creates a working 3-folder shared dev environment for production web (or other) server site
	-master_location# Where to store the master filess (defaults to ~/gitblobs/)
	-group		# which groupname do all developers belong to
	-owner		# which user should own this (e.g. if you run this script as root)
	-public		# put author email into .git-meta file
	-autopush	# adds a post-commit hook that automatically does a "git push" every time you commit. (only works for the -setup command)
	-debug		# print everything going on
	-help		# show this help

=head2 .git-meta file format

	# lines starting with # are comments
	octal file mode, owner, group, mtime, atime, spare1, spare2, filename

=cut

#	=head2 known issues
#	
#		Only handles .gitignore files found inside your repo (not any set in your profile or elsewhere)
#	
#	
#	=head2 TODO
#	
#		(all done)


=head1 FILENAMES

.git/hooks/pre-commit     - this same perl script, when it has the name "pre-commit" assumes you're running "git-meta.pl -save"
.git/hooks/post-checkout  - this same perl script, when it has the name "post-checkout" assumes you're running "git-meta.pl -restore"
.git/hooks/post-merge     - this same perl script, when it has the name "post-merge" assumes you're running "git-meta.pl -restore"
newgit.pl                 - this same perl script, when it has the name "newgit.pl", behaves as if the -newgit option was supplied - see below.


newgit.pl - create a new, optionally auto-extracting, private git repo, with preservation of file metadata (dates/time, permissions, ownership)
 -or-
git-meta.pl -newgit

=head1 -newgit Synopsis

	newgit.pl gitname [optional-auto-extract-location]
	# creates gitname				# this is where master files live. Uses $master_location/gitname unless gitname starts with /
	# creates ./gitname				# this is a local working folder for editing your files etc (you can "git clone" more of these later)
	# maybe creates optional-auto-extract-location	# this is where they'll be auto-extracted (properly includes mv/rm etc) upon all git push operations

	SCREW_UP_DATES=1 newgit.pl gitname [optional-auto-extract-location]
	# same as above, omitting the hooks which preserve dates/permissions/ownership

	DRYRUN=1 newgit.pl gitname [optional-auto-extract-location]
	DRYRUN=1 SCREW_UP_DATES=1 newgit.pl gitname [optional-auto-extract-location]
	# same as either of the above two, but doing nothing (shows what commands will be executed)

=head2 Linux

	Works natively

=head2 Windows

	If this code is run inside Windows, it re-launches itself inside WSL to do its work.

=head2 Mac

	Not tested

=head2 Example

	newgit.pl leoweb ~/leo/public_html

=head2 File location info

	if there's no "/" within "gitname", it will put the files into $master_location/gitname (e.g. ~/gitblobs/gitname ) by default

=cut
######################################################################


use bytes;		# don't break UTF8
use strict;
use warnings;		# same as -w switch above

use POSIX;		# for strftime
use Time::HiRes;	# Getting file microseconds
#use Getopt::Long qw(:config require_order);	# Commandline argument parsing
use Getopt::Long;	# Commandline argument parsing
#use Pod::Usage;		# Inbuilt documentation helper
#use Cwd;
require Cwd;
Cwd->import() unless(defined &main::getcwd);  # Manually call import() to load functions like getcwd (which other modules might have done before; getcwd is not well behaved)
my %gitignore;		# global
my %names;my $i=0;$names{$_}=$i++ foreach(qw(mode owner group mtime atime spare1 spare2 filename));

my $is_tty_out = (!-f STDOUT) && ( -t STDOUT && -c STDOUT);	# -f is a file, -t is a terminal, -c is a character device
my ($norm,$red,$grn,$yel,$nav,$blu,$save,$rest,$clr,$prp,$wht)=!$is_tty_out ? ('','','','','','','','','','','') : ("\033[0m","\033[31;1m","\033[32;1m","\033[33;1m","\033[34;1m","\033[36;1m","\033[s","\033[u","\033[K","\033[35;1m","\033[37;1m"); # so we can print colour output if we want.
my(@oriargs)=@ARGV;
my $gitprog=''; open(IN,'<',$0) or die "Could not open file '$0' $!";
$gitprog.=$_ while(<IN>);
close(IN); # Reads in ourself - for git-meta.pl to use
my @pfn;
my $pprint = "$blu# Created with https://github.com/gitcnd/git-meta.git v$VERSION command:-$norm\n\n$0 " . join(" ",@ARGV) . "\n$norm\n";

my %arg;&GetOptions('help|?'	=> \$arg{help},			# breif instructions
		    'master_location=s'	=> \$arg{master_location}, # defaults to $ENV{"HOME"}."/gitblobs";
		    'f=s'	=> \$arg{gitmeta},		# meta filename
		    'group=s'	=> \$arg{group},		# which groupname do all developers belong to
		    'owner=s'	=> \$arg{owner},		# which owner for it all (when run as root)
		    'l=s'	=> \$arg{l},			# expects the name of this program. Use "." to use the `pwd`/$0
		    'c=s'	=> \$arg{c},			# "cd" into this folder first
		    'save'	=> \$arg{save},			# Save into the .git-meta. Saves all files if none are provided
		    'restore'	=> \$arg{restore},		# Restore from the .git-meta. Restores all files if none are provided
		    'autopush'	=> \$arg{autopush},		# adds a post-commit hook that automatically does a "git push" every time you commit. (only works for the -setup command)
		    'strict'	=> \$arg{strict},		# stop instead of assume 
		    'public'	=> \$arg{public},		# show email
		    'debug'	=> \$arg{debug},		# print everything going on
		    'setup'	=> \$arg{setup},		# create the necessary pre-commit and post-checkout files to activate this solution in your repo
		    'dryrun'	=> \$arg{dryrun},		# not fully implemented!
		    'newgit'	=> \$arg{newgit},		# creates a working 3-folder shared dev environment for production web (or other) server site
	   ) or &pod2usage(2); 
no warnings;
	   &pod2usage(1) if ($arg{help});			# exits
use warnings;
# $arg{debug}=1;

$arg{gitmeta}=".git-meta" unless($arg{gitmeta});
$arg{dryrun}=$ENV{'DRYRUN'} unless($arg{dryrun});		# debugging - set the switch or env var to 1 if you want to print, but not execute, the commands
my $dryrun=$arg{dryrun};
$arg{c}=1 unless($arg{c});
my $last=$arg{public} ? '# last:() <>' : '# last:() ';
my($myuid,$mygid); # set in &lastline
$mygid="" . getgrnam($arg{group}) . ':' . $arg{group} if($arg{group});
warn "mygid=$mygid" if($arg{debug});
my $gidb=(split(/ /,$( ))[0]; 


sub d2l {
  #my($dospath)=@_;			# C:\Users\cnd\Downloads\mygit.pl
  $_[0]=~s/\\/\//g;              	# C:/Users/cnd/Downloads/mygit.pl
  $_[0]=~s/^(\w):/\L\/mnt\/$1/;	# /mnt/c/Users/cnd/Downloads/mygit.pl
  $_[0]=~s/'/'"'"'/g;		# handle Folder's insanity (gets wrapped in 'apos' later you see...)
  $_[0]=~s/\$/\\\\\\\$/g;		# Windows requires 3 \ in front of all $ to stop bash interpreting them
  return $_[0]; # now a WSL linux path :-)
} # d2l
sub chompnl {# chomp() on unix doesn't eat "\r"...
  chop $_[0] while((substr($_[0],-1) eq "\015")||(substr($_[0],-1) eq "\012"));
} # chompnl

sub shellsafe { # make filenames with ugly's spaces and mess! work inside bash 'apos'
  my($fn)=@_;
  &chompnl($fn);
  $fn=~s/([\$\#\&\*\?\;\|\>\<\(\)\{\}\[\]\"\'\~\!\\\s])/\\$1/g;
  return $fn;
} # shellsafe
sub pod2usage { # standard perls do not always have access to Pod::Usage
  my($ec)=@_;
  if($ec) {
    my $in_pod = 0;
    open my $fh, '<', $0 or die "Can't open file: $!";  # Open the script itself
    while (<$fh>) {
      last if /^__END__/;
      $in_pod = 1 if (/^=(pod|head\d|over|item|back|begin|for|end)/);
      print if $in_pod;
      $in_pod = 0 if (/^=cut/);
    }
    close $fh;
  } # #1
  #print "$ec: $!";
  exit($_[0]);
} # pod2usage


die "infinte recursive loop detected: $^O $0 " . getcwd() . " c=$arg{c}" if($arg{c}>3); # prevent loop

#	$^O	eq 'MSWin32'	$os eq 'darwin'		$os eq 'linux'
if($^O eq 'MSWin32') { # Make this code work on windows too (if WSL exists)
  # die "This code ($0 " . join(" ",@ARGV) . ") is not $^O compatible, sorry." 
  my $pwd =&d2l( getcwd() );
  my $pgm=&d2l($0);
  my @ac=@oriargs; # @ARGV;
  foreach (@ac) { &d2l($_) if /^(\w):/ }
  
  # $pgm = "$pwd/$pgm" unless($pgm=~/^\//); # figure out full path

  print "Re-running '$pgm' in folder '$pwd' under WSL (this code is not compatible with $^O)\n";
  # system('bash.exe','-c','pwd;echo pwd'); system('bash.exe','-c','ls -a;echo ls'); system('bash.exe','-c','echo env;env'); system('bash.exe','-c','echo set;set'); system('bash.exe','-c','echo whoami;whoami');

  #my @lnxarg=('C:\Windows\system32\wsl.exe','-e','perl',$pgm,'-c',$arg{c}+1);
  my @lnxarg=('C:\Windows\system32\wsl.exe','-e','perl',$pgm);
  push @lnxarg,@ac;

  #die join("^",@lnxarg);
  # push @lnxarg,'-setup' if($arg{setup});
  # push @lnxarg,'-autopush' if($arg{autopush});
  my $rc=system( @lnxarg );
  #my $rc=system('C:\Windows\system32\wsl.exe','-e','perl',$pgm,'-c',$arg{c}+1); # pushd/popd missing...
  my $ec=$?>>8;
  print "Ran. rc=$rc ec=$ec\n";
  #system('bash.exe','-c',"perl $pgm -c 2"); # pushd/popd missing...
  #system('bash.exe','-c','export GHERE=`pwd`;' . "cd '$pwd'; '$pgm'; " . 'cd $GHERE'); # pushd/popd missing...
  exit(0); # die "This code ($0 " . join(" ",@ac) . ") in $pwd is not $^O compatible, sorry." # This code (.git/hooks/pre-commit ) in /mnt/c//Users/cnd/Downloads/cursor/voicetype is not MSWin32 compatible, sorry. at .git/hooks/pre-commit line 256.
} else {
  print "Running '$0' under $^O in folder: ".`pwd`;
}

if($arg{l} && $arg{l} eq '.') {
  $arg{l}=$0; $arg{l}=`pwd` . "/$0" unless($arg{l}=~/^\//);
}

#die "$0: " . join("^",%arg) . "\t" . join("^",@ARGV);
# Change the personality of this program, depending on what name $0 it has:
if($0=~/pre-commit/) {
  &GetMyGid($arg{gitmeta});
  $arg{save}=1;
  my @staged_files=`git diff --cached --name-only`;
  chomp(@staged_files);
  @staged_files=('.') unless(@staged_files);
  # warn "$blu doing:" . join("^",@staged_files) . "$norm\n";
  # print "$blu doing:" . join("^",@staged_files) . "$norm\n";
  @ARGV=@staged_files;
}

if($0=~/post-checkout/) {
  &GetMyGid($arg{gitmeta});
  $arg{restore}=1;
  @ARGV='.'; # do/check everything
}

if($0=~/post-merge/) {
  &GetMyGid($arg{gitmeta});
  $arg{restore}=1;
  @ARGV='.'; # do/check everything
}

if($0=~/post-commit/) {
  &GetMyGid($arg{gitmeta});
  &do("git push");
  exit(0);
}

if($0=~/newgit/) {
  $arg{newgit}=1;
}






######################################################################
if($arg{newgit}) {
  die "This script must not be run as root or with sudo!" if ($< == 0 || $> == 0);
  

  $ENV{'MY_GIT_META_GID'} = $mygid;
  warn "############      mygid=$mygid" if($arg{debug});

  # newgit settings
  
  my $master_location=$arg{master_location} ? $arg{master_location} : $ENV{"HOME"}."/gitblobs"; # Change this to whatever default folder you want to use for storing master copies of files
  $master_location=glob($master_location); chop $master_location if($master_location=~/\/$/);

  # This is the folder where all the gitblob folders will live
  &do("mkdir -p $master_location") unless(-d $master_location);
  &do("sudo chgrp $arg{group} $master_location") if($arg{group});
  &do("sudo chown $arg{owner} $master_location") if($arg{owner});
  &do("chmod ug+rwx $master_location"); # let other people in our group write into this
  &do("chmod g+s $master_location"); # default to allow above on new files
  &do("sudo setfacl -d -m g::rwx $master_location");	# Assumes: zfs set acltype=posixacl your_dataset_name; zfs set xattr=sa your_dataset_name # on zfs
  
  $ARGV[0]='-' unless($ARGV[0]); # see next
  foreach(@ARGV){die "Usage:\t$0 gitname [optional-auto-extract-location]" if(/^-/);} # stop if they're confused
  foreach(keys(%arg)){die "Usage:\t$0 gitname [optional-auto-extract-location]" if(defined($arg{$_}) && $arg{$_}=~/^-/);} # stop if they're confused


  my $gitblob=glob($ARGV[0]); $gitblob="$master_location/$ARGV[0]" unless($ARGV[0]=~/\//);
  die "Sorry, $gitblob exists" if(-e $gitblob);
  my $gitnamee=&shellsafe(glob($ARGV[0]));

  my $gitblobe=&shellsafe($gitblob);

  my $workblob=glob($ARGV[0]);
  my $workblobe=&shellsafe(glob($ARGV[0]));

  my $autotarget=glob($ARGV[1]) if($ARGV[1]);
  chop $autotarget if($autotarget=~/\/$/);
  my $autotargete=&shellsafe(glob($ARGV[1]));
  my $pwd=&shellsafe(`pwd`); chomp($pwd);
  
  my $auto_hookfolder='';  
  $auto_hookfolder="$autotarget/hooks" unless($auto_hookfolder && -d $auto_hookfolder);
  $auto_hookfolder="$autotarget/.git/hooks" unless(-d $auto_hookfolder);

  my $work_hookfolder='';  
  $work_hookfolder="$workblob/hooks" unless($work_hookfolder && -d $work_hookfolder);
  $work_hookfolder="$workblob/.git/hooks" unless(-d $work_hookfolder);

  $workblobe="$pwd/$workblobe" unless($workblobe=~/^\//);
  $autotargete="$pwd/$autotargete" unless(!$autotarget || $autotargete=~/^\//);

  die "no master location specified" unless($gitblobe);
  die "no work blob specified" unless($workblobe);
  die "cannot determine pwd" unless($pwd);
  my ($usrpfx,$usrsfx)=$arg{owner} ? ("su - $arg{owner} -c '","'") : ('',''); # runs with "su -" if they specified an owner


  &msg("# Create the master location");
  &do("mkdir -p $gitblobe");	# ~/gitblobs/foo
  &do("chgrp $arg{group} $gitblobe") if($arg{group});
  &do("chown $arg{owner} $gitblobe") if($arg{owner});
  &do("chmod g+rwx $gitblobe"); # let other people in our group write into this
  &do("chmod g+s $gitblobe"); # default to allow above on new files
  &do("setfacl -d -m g::rwx $gitblobe");

  &do("cd $gitblobe;git init --bare;cd $pwd");
  my $chowner=$arg{owner} ? "chown -R $arg{owner} $gitblobe;" : '';
  $chowner.=$arg{group} ? "chgrp -R $arg{group} $gitblobe;" : '';
  &do($chowner) if($chowner);


  &msg("# Create one initial working folder");
  &do("git clone $gitblobe $workblobe");
  &do("chgrp $arg{group} $workblobe") if($arg{group});
  &do("chown $arg{owner} $workblobe") if($arg{owner});
  &do("chmod g+rwx $workblobe") if($arg{group}); # let other people in our group write into this
  &do("chmod g+s $workblobe") if($arg{group}); # default to allow above on new files
  &do("setfacl -d -m g::rwx $workblobe") if($arg{group});

  $chowner=$arg{owner} ? "chown -R $arg{owner} $workblobe;" : '';
  $chowner.=$arg{group} ? "chgrp -R $arg{group} $workblobe;" : '';
  &do("$chowner${usrpfx}cd $workblobe;touch README.txt;git add README.txt;git commit -m Setup; git config push.default current; git push;cd $pwd$usrsfx") if($arg{group});


  unless($ENV{'SCREW_UP_DATES'}) {
    &msg("# Setting up '$workblob' to preserve dates");
    &preserve_dates($work_hookfolder);
    &pprint($blu."If doing \"git clone\" in other machines later, remember to copy the following files into your new location .git/hooks/ folder too:\n\t".join("\n\t",@pfn)."$norm\n");
  }
  if($arg{autopush}) {
    &makehook("$work_hookfolder/post-commit");
  }
  &BlockApache($auto_hookfolder);
  &BlockApache($work_hookfolder);

  # re-do, to be safe
  $chowner=$arg{owner} ? "chown -R $arg{owner} $gitblobe;" : '';
  $chowner.=$arg{group} ? "chgrp -R $arg{group} $gitblobe;" : '';
  &do($chowner) if($chowner && $arg{group});
  &do("pushd $gitblobe;chmod ug+rw `find .`; chmod ug+rwx `find . -type d`; chmod g+s `find . -type d`;popd") if($arg{group});
  $chowner=$arg{owner} ? "chown -R $arg{owner} $workblobe;" : '';
  $chowner.=$arg{group} ? "chgrp -R $arg{group} $workblobe;" : '';
  &do($chowner) if($chowner && $arg{group});
  &do("pushd $workblobe;chmod ug+rw `find .`; chmod ug+rwx `find . -type d`; chmod g+s `find . -type d`;popd") if($arg{group});

  # Set up auto-extract if wanted
  if($autotargete) {
    &msg("# Set up auto-extract into $autotargete");
    my $autotargetee=$autotargete; $autotargetee=~s/\\/\\\\/g;
    if(!-e $autotargete){
      # &do("mkdir -p $autotargete") unless(-e $autotarget);
    } else {
      &pprint($red."Caution: '$autotarget' exists: files in here will be overwritten by future 'git push' operations$norm\n");
    }
    &do("git clone $gitblobe $autotargete");

    my $fixgrp='';
    $fixgrp="chgrp -R $arg{group} . 2>/dev/null\n" if($arg{group});
    $fixgrp.="chown -R $arg{owner} . 2>/dev/null\n" if($arg{owner});
    $fixgrp ="cd $gitblobe\n" . $fixgrp if($fixgrp);
    &do("cd $gitblobe/hooks/;cat >post-update <<\\EOF
#!/bin/bash
printf \"post-update ($gitblobe/hooks/post-update): running in $autotargetee...\\n\"
pushd $autotargetee
$fixgrp
cd $autotargetee;env -u GIT_DIR git reset --hard; env -u GIT_DIR git pull || exit
$fixgrp
popd
printf \"post-update: ran ok $autotargetee\\n\"
EOF");

    &do("cd $gitblobe/hooks/;chmod ug+rwx post-update;cd $pwd");
    &do("cd $autotargete; git config pull.default current;cd $pwd");
    &do("touch $autotargete/AUTOGENERATED_FOLDER-DOT_NOT_EDIT");
    &BlockApache("$autotargete/.git/hooks");
  
    unless($ENV{'SCREW_UP_DATES'}) {
      &msg("# Setting up '$autotarget' to preserve dates");
      &preserve_dates($auto_hookfolder);
    }

    # re-do, to be safe
    $chowner=$arg{owner} ? "chown -R $arg{owner} $autotargete;" : '';
    $chowner.=$arg{group} ? "chgrp -R $arg{group} $autotargete;" : '';
    &do($chowner) if($chowner && $arg{group});
    &do("pushd $autotargete;chmod ug+rw `find .`; chmod ug+rwx `find . -type d`; chmod g+s `find . -type d`;popd")  if($arg{group});

    
  } # autotargete

  # git config --global --add safe.directory /home/cnd/Downloads/gitblobs/workfolder
 
 
  my $hostname=`hostname`;chomp($hostname);
  &msg("$blu# Done! Try these next perhaps:$wht
pushd $ARGV[0]
echo hello > index.html
git add index.html
git commit -m Initial_Commit
git push
popd
" . ( $autotarget? "dir $autotarget\n" : "") . "$blu# And on some other machine:-$wht
git clone ssh://$hostname$gitblob
cd $ARGV[0]
git-meta.pl -setup " . ( $arg{'l'}? "-l . ":"") . ( $arg{'owner'}? "-owner $arg{'owner'} ":"") . ( $arg{'group'}? "-group $arg{'group'} ":"") . ( $arg{'autopush'}? "-autopush ":"") . "
$blu# (always remember to \"git pull\" before changing things when you're using multiple machines!)$norm" );
  # Done!

  if(1) {
    open(OUT,'>>',"$workblobe/README.txt") or die "$workblobe/README.txt:$!";
    print OUT $pprint;
    close(OUT);
    `cd $workblobe;git add README.txt;git commit -m Setup; git config push.default current; git push;cd $pwd`; # Save info about how we were set up
  }

  exit(0);
} # newgit
######################################################################









if($arg{setup}) {
  my $hookfolder='.git/hooks';
  $hookfolder='hooks' unless(-d $hookfolder);
  die "No hooks folder: must run this from inside your repo folder." unless(-d $hookfolder);

  &preserve_dates($hookfolder);
  &BlockApache($hookfolder);

  if($arg{autopush}) {
    &makehook("$hookfolder/post-commit");
  }
  print `.git/hooks/post-merge` if(-e '.git-meta');

  exit(0);
} # setup

my(@meta,%meta); &LoadMeta($arg{gitmeta});			# Get existing metadata


if($arg{save}) {
  &GetIgnore();
  @ARGV='.' unless(@ARGV);					# do all if none specified
  &GetMeta(undef,@ARGV);					# Append new metadata to @meta
  &SaveMeta($arg{gitmeta});					# Write new metadata to file
  `git add $arg{gitmeta}` if($0=~/pre-commit/);			# save the metadata with this commit too
} elsif($arg{restore}) {
  &GetIgnore();
  @ARGV='.' unless(@ARGV);					# do all if none specified
  my @files=&GetMeta('nosave',@ARGV);				# which files to restore
  &RestoreMeta(@files);						# restore all or some file metadatas
  
} else {
  &pod2usage(1);
}



# warn '%meta='. join("^",%meta); warn '@meta='. join("^",@meta);



# Load the .gitignore file into a hash
sub GetIgnore {
  $gitignore{'.git'}++ if(-e '.git');	# don't do the git blobs
  $gitignore{$arg{gitmeta}}++;		# don't do our own metafile
  #$gitignore{'./.git'}++ if(-e '.git');
  if(-e '.gitignore') {
    open(IN,'<','.gitignore') or die "open .gitignore: $!";
    while(<IN>) {
      chomp; $gitignore{$_}++; # $gitignore{"./$_"}++;
    }
    close(IN);
  }
} # GetIgnore

sub BlockApache { # web-safety 1st.
  my($hookfolder)=@_;
  my $htaccess=&canonicalize_path("$hookfolder/../.htaccess"); # Parent of hook folder
  my $index=&canonicalize_path("$hookfolder/../index.html"); # Parent of hook folder
  if(-e $htaccess) {
    &pprint($yel."Caution: moved existing $htaccess to $htaccess.save$norm\n");
    rename($htaccess,"$htaccess.save") unless($dryrun);
  }
  if(-e $index) {
    &pprint($yel."# Caution: moved existing $index to $index.save$norm\n");
    rename($index,"$index.save") unless($dryrun);
  }
  unless($dryrun) {
    open(OUT,'>',$htaccess) or warn "$htaccess $!";
    print OUT "<RequireAll>\n    Require all denied\n</RequireAll>\n";
    close(OUT);
    &pprint($yel."# Created $htaccess with \"Require all denied\"\n");
    open(OUT,'>',$index) or warn "$index: $!";
    print OUT "\n";
    close(OUT);
    &pprint($yel."# Created empty $index\n");
  }
} # web-safety 1st.

# Update @meta and %meta with metadata from a filesystem file or folder
sub MetaFile {
  my($nosave,$filename)=@_;

  my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks)=Time::HiRes::lstat($filename); # the symlink itself, not the target

  # Retrieve specific file information
  my $modefix = (-d $filename) ? 0770 : 0660; # must not block other people in our group from writing to folders!
  
  my $permissions = sprintf "%04o", $mode & 07777 | $modefix;
  # $permissions = '0644' if(!$permissions || $permissions eq '0000'); # don't permit locking ourself out

  # Convert numeric user ID and group ID to names
  my $owner_name = $myuid; $owner_name=~s/.*://; # getpwuid($uid);
  my $group_name = $mygid; $group_name=~s/.*://; # getgrgid($gid);

  $mtime = Time::HiRes::time() if !defined($mtime);
  $atime = $mtime if !defined($atime);
  $ctime = $mtime if !defined($ctime);


  my $microsecs_m=($mtime=~/(\.\d+)/)[0] // ""; # returns .456 or (if no decimal places) just ""
  my $humantime_m= strftime("%Y-%m-%d %H:%M:%S",localtime($mtime)) . $microsecs_m . strftime(" %z", localtime()) ;
  my $microsecs_a=($atime=~/(\.\d+)/)[0] // ""; # returns .456 or (if no decimal places) just ""
  my $humantime_a= strftime("%Y-%m-%d %H:%M:%S",localtime($atime)) . $microsecs_a . strftime(" %z", localtime()) ;
  # For later use thusly: touch -hcmd "2023-11-10 06:39:09.1234 +0000" filename

  my @fm=($permissions, $owner_name, $group_name, $humantime_m, $humantime_a,"","",$filename);

  return \@fm if($nosave); # restore-er made the call

  # warn join(",",@fm);
  # warn join(",",@{$meta[ $meta{$fm[-1]} ]}) if (defined  $meta{$fm[-1]} );

  if ( (! defined $meta{$fm[-1]})  ||  (join(",",@{$meta[ $meta{$fm[-1]} ]}) ne join(",",@fm) ) ) {
    push @meta,\@fm; # store everything in the original order inside an array
    $meta{$fm[-1]}=$#meta; # keep a searchable hash of the filenames as we go.  This on-purpose will overwrite old duplicates with new times later.
    print "STORED: ARRAY $fm[-1] at index $#meta\n" if($arg{debug});
  } else {
    print "Skipped unchanged file $fm[-1]\n" if($arg{debug});
  }

  if(0 && $arg{debug}) {	# Display the retrieved information
    print "File: $filename\n";
    print "Permissions suitable for chmod: $permissions\n";
    print "Owner: $owner_name\n";
    print "Group: $group_name\n";
    print "Last Modification Time (touch format): $mtime\n";
    print "Last Modification Time (human + format): $humantime_m\n";
    print "Last Access Time (touch format): $atime\n";
    print "Last Access Time (human + format): $humantime_a\n";
    print '(' . join(',',@fm) . ")\n";
  } # debug

  return \@fm;
} # MetaFile



# Load a .git-meta file into @meta and %meta
sub LoadMeta {
  my($metafile)=@_;
  warn "mygid=$mygid" if($arg{debug});
  if(!-f $metafile) {
    die "Expecting -f $metafile" if $arg{strict};
    print STDERR $yel."Warning: no $metafile" . ($arg{save} ? " (it will be created next)" : "") . "$norm\n";
    $mygid=$ENV{'MY_GIT_META_GID'} if($ENV{'MY_GIT_META_GID'});
    warn "######## mygid=$mygid" if($arg{debug});
  } else {
    open(IN,'<',$metafile) or die "$metafile: $!";
    while(<IN>) {
      chomp;
      my $fm=$_; 
      if(/^\s*#/) { # CAUTION - THIS IN 2 PLACES
        if($fm=~/^# last:/){ # if this has < in it, git-meta will include commit author email in comments
          $last=$fm;
          &lastline($last,"name","email"); # Sets $myuid/$mygid
        }
      } else {
        my @fm=split(/,/,$_,8); $fm=\@fm;
	if (ref $meta{$$fm[-1]} && join(',',@{$meta{$$fm[-1]}}) eq $_) {
	  $fm=undef;
	  print "Skipping unchanged file info for $$fm[-1]\n" if($arg{debug});
	}
      }
      push @meta,$fm; # store everything in the original order inside an array
      print "STORED: $fm at index $#meta\n" if($arg{debug});
      $meta{$$fm[-1]}=$#meta if(ref $fm); # keep a searchable hash of the filenames as we go.  This on-purpose will overwrite old duplicates with new times later.
    }
    close(IN);
  }
  warn "mygid=$mygid" if($arg{debug});
} # LoadMeta



sub GetMyGid {
  my($metafile)=@_;
  if(!-f $metafile) {
    &lastline("","name","email"); # sets initial $myuid and $mygid
  } else {
    open(IN,'<',$metafile) or die "$metafile: $!";
    my $max=5;
    while(<IN>) {
      last if($max--<0);
      chomp;
      my $fm=$_;
      if(/^\s*#/) { # CAUTION - THIS IN 2 PLACES
        if($fm=~/^# last:/){ # if this has < in it, git-meta will include commit author email in comments
          $last=$fm;
          &lastline($last,"name","email"); # Sets $myuid/$mygid
        }
      }
    }
  }
  warn "mygid=$mygid" if($arg{debug});
} # GetMyGid



# Make a single-line comment for out .git-meta file, which also includes the uid/gid so we can use those as defaults if they're missing on some platform later (e.g. windows)
sub lastline {
  my($lastlast, $commit_user_name, $commit_user_email, $uid, $gid)=@_;
  my($lastuid,$lastgid)=($lastlast=~/^# last:\(([^,]+),([^,]+)\)/) if($lastlast);
  warn "mygid=$mygid lastgid=$lastgid" if($arg{debug});
  unless($uid) {
    $uid=$< . ":" . ( $< ? "" . getpwuid($<) : "unknown"); # 500:cnd
    $uid=$lastuid if($uid=~/unknown/);
  }
  $gid=$mygid if(!$gid && $mygid); # the "group" part needs to be sticky, so shared-editing always works
  unless($gid) {
    $gid=$gidb . ":" . ( $gidb ? "" . getgrgid($gidb) : "unknown"); # 500:cnd
    warn "mygid=$mygid gid=$gid \$(=$( getgrgid=".getgrgid($() if($arg{debug});
    $gid=$lastgid if($gid=~/unknown/);
  }
  warn "mygid=$mygid gid=$gid" if($arg{debug});

  unless($commit_user_name) {
    $commit_user_name=`git config user.name`; chomp $commit_user_name;
  }
  if($lastlast && ($lastlast!~/</) && !$commit_user_email) {
    $commit_user_email=`git config user.email`; chomp $commit_user_email;
    $commit_user_email=" <$commit_user_email>";
  }
  $commit_user_email='' unless(defined $commit_user_email);

  my $ret="# last:($uid,$gid) $commit_user_name$commit_user_email at " . strftime("%Y-%m-%d %H:%M:%S %z",localtime());
  $myuid=$uid;
  $mygid=$gid unless($mygid);
  warn "mygid=$mygid" if($arg{debug});
  return $ret;
} # lastline



# Write out (overwrite) our @meta and %meta into the .git-metafile, keeping original order
sub SaveMeta {
  my($metafile)=@_; my %done;
  open(OUT,'>',$metafile) or die "write: $metafile: $!";
  warn "mygid=$mygid" if($arg{debug});

  # my $current_branch=`git rev-parse --abbrev-ref HEAD`; chomp $current_branch;

  print OUT "# octal file mode, owner, group, mtime, atime, spare1, spare2, filename\t# https://github.com/gitcnd/git-meta.git v$VERSION\n" if(ref $meta[0]);
  #print OUT "# last: $commit_author\n" if(ref $meta[0]);
  print OUT &lastline($last)."\n" if(ref $meta[0]);

  for(my $i=0; $i<=$#meta;$i++) {
    # warn "i=$i"; warn "fn=" . $meta[$i]->[-1]; warn "idx=" . $meta{ $meta[$i]->[-1] };
    if(!ref $meta[$i]) { # comment
      if($meta[$i]=~/^# last: /) {
        #print OUT "# last: $commit_author\n"; # discard the old last: author remark
        print OUT &lastline($last)."\n"; # discard the old last: author remark
        warn &lastline($last) if($arg{debug});
      } else {
        print OUT $meta[$i] . "\n";
        warn $meta[$i] if($arg{debug});
      }
    } elsif( !$done{$meta[$i]->[-1]}++ ) {      #   $meta{ $meta[$i]->[-1] }==$i )      # new or unchanged
      my $fn=$meta[$i]->[-1]; # the list
      my $newest_i=$meta{ $fn }; # the hash
      if(-e $fn) {
        print OUT join(',',@{$meta[$newest_i]}) . "\n";   # "$meta[$i]->[-1]" is the filename, and the outer $meta{  } is the hash of the filename, which contains the @meta index number of the most recent info to use
        warn join(',',@{$meta[$newest_i]}) if($arg{debug});
      } else {
        warn "Skipped non-exist:" . join(',',@{$meta[$newest_i]}) if($arg{debug});
      }
    } else {
      print "Skipping appended $meta[$i]->[-1] at index $i because we earlier overwrote the older one from here: $meta{ $meta[$i]->[-1] }\n" if($arg{debug});
    }
  }
  close(OUT);
} # SaveMeta



# Recursively spider the input set of files, calling MetaFile on them all to add them into @meta and %meta
sub GetMeta {
  my ($nosave,@files) = @_;

#warn join("^",@files);

  for(my $i=0; $i<=$#files;$i++) {
    my $f=$files[$i];
#warn "$i: $f";
    if(-d $f && !-l $f) {
      opendir(my $dh, $f) or die "Could not open '$f' for reading: $!";
      while (my $subfile = readdir($dh)) {
        next if $subfile eq '.' or $subfile eq '..';
        push @files, ($f eq '.' ? $subfile : "$f/$subfile") unless($gitignore{$f} || $gitignore{"$f/$subfile"}); #  || $f eq '.' );
      }
      closedir($dh);
    }
    &MetaFile($nosave,$f) unless($nosave || $gitignore{$f} || $f eq '.');	# add file *and* folders to .git-meta @meta and %meta ram storage

  } # for
  return @files;
} # GetMeta



# restore metadata for the named files
sub RestoreMeta {
  my (@files) = @_;
  my $fixed=0;

  foreach my $f (@files) {
    if( ! $meta{ $f } ) {
      print "No metadata for $f... skipping\n" if($arg{debug});
      next;
    }

    my $nowfm=&MetaFile('nosave',$f);
    my $newfm=$meta[ $meta{ $f } ]; my $n;
    my $qmf=&shellsafe($f); # $qmf=~s/([\$\#\&\*\?\;\|\>\<\(\)\{\}\[\]\"\'\~\!\\\s])/\\$1/g;        # shell-escape for dummies who use spaces in filenames

    if ( join(',',@$nowfm) ne join(',',@$newfm) ) {
      # mode owner group mtime atime spare1 spare2 filename

      $n='mode';
      if( $nowfm->[$names{$n}] ne $newfm->[$names{$n}] ) {
	my $cmd="chmod $newfm->[$names{$n}] $qmf";
	print "$grn$cmd$norm\n" if($arg{debug});
	print $yel . `$cmd` . $norm unless($dryrun);
      } elsif($arg{debug}){
	print "$blu same: $nowfm->[$names{$n}] == $newfm->[$names{$n}] $n$norm\n";
      }

      $n='owner';
      if( $nowfm->[$names{$n}] ne $newfm->[$names{$n}] && $newfm->[$names{$n}]) {
	my $cmd="chown $newfm->[$names{$n}] $qmf";
	print "$grn$cmd$norm\n" if($arg{debug});
	print $yel . `$cmd` . $norm unless($dryrun);
      }

      $n='group';
      if( $nowfm->[$names{$n}] ne $newfm->[$names{$n}] ) {
	my $cmd="chgrp $newfm->[$names{$n}] $qmf";
	print "$grn$cmd$norm\n" if($arg{debug});
	print $yel . `$cmd` . $norm unless($dryrun);
      }

      $n='mtime';
      if( $nowfm->[$names{$n}] ne $newfm->[$names{$n}] ) {
	my $cmd="touch -hcmd \"$newfm->[$names{$n}]\" $qmf";
	print "$grn$cmd$norm\n" if($arg{debug});
	print $yel . `$cmd` . $norm unless($dryrun);
      }

      $n='atime';
      if( $nowfm->[$names{$n}] ne $newfm->[$names{$n}]  && $f ne '.gitignore') {	# we read this ourselves, so the atime always changes
	my $cmd="touch -hcad \"$newfm->[$names{$n}]\" $qmf";
	print "$grn$cmd$norm\n" if($arg{debug});
	print $yel . `$cmd` . $norm unless($dryrun);
      }
      $fixed++;
    } else {
      print "Skipping unchanged file $f\n" if($arg{debug});
    }
  }
  return $fixed
} # RestoreMeta


# Caution: these subs msg and do in 3 places
sub msg{ &pprint("\n$wht$_[0]$norm\n"); }
sub do {
  my($cmd)=@_;
  &pprint("$grn$cmd$norm\n");
  print $yel.`$cmd`.$norm unless($dryrun);
}

sub makehook {
  my($fn)=@_;

  if(!$dryrun) {
    if(-e $fn) {
      &pprint($yel."Caution: moved existing $fn to $fn.save$norm\n");
      rename($fn,"$fn.save");
    }
  }

  if($arg{l}) {
    &do("ln -s $arg{l} $fn");
  } else {
    open(OUT,'>>',$dryrun ? '/dev/null' : $fn) or die "Cannot create file '$fn': $!";
    print OUT $gitprog; close(OUT); 
    &pprint($grn . "cat $0 >> $fn$norm\n");
  }

	#commit_author="$(git config user.name)"" <""$(git config user.email)"">" 
	#commit_message=$(cat $1)
	#current_branch=$(git rev-parse --abbrev-ref HEAD) #from https://dev.to/anibalardid/how-to-check-commit-message-and-branch-name-with-git-hooks-without-any-new-installation-n34
	#https://github.com/typicode/husky/discussions/1171

	# Get a list of all staged files
	#staged_files=$(git diff --cached --name-only)

	#bash .git/hooks/git-meta --store
	#git add .git-meta
	# echo "Done. Meta has been preserved!"

  my $fne=&shellsafe($fn); # $fne=~s/([\$\#\&\*\?\;\|\>\<\(\)\{\}\[\]\"\'\~\!\\\s])/\\$1/g;
  &do("chmod ugo+x $fne");
} # makehook

# CAUTION!! This code in 3 places (inside newgit.pl, and ALSO inside git-meta.pl and in the the pre-commit and post-checkout DATA sections of newgit.pl)
sub preserve_dates {
  my($hookfolder)=@_;

  die "No hooks folder ($hookfolder from ".`pwd`."): must run this from inside your repo folder." unless(-d $hookfolder);

  foreach("$hookfolder/pre-commit", "$hookfolder/post-merge", "$hookfolder/post-checkout") {
    &makehook($_);
    push @pfn,$_;
  }
  &do("chown -R $arg{owner} $hookfolder") if($arg{owner});
  &do("chgrp -R $arg{group} $hookfolder") if($arg{group});
  &do("pushd $hookfolder/..; git config --local core.fileMode false;popd"); # so future "pull" doesn't choke after the hook changed permissions.

} # preserve_dates

sub canonicalize_path {
  my ($path) = @_;
  my @parts = split('/', $path);
  my @stack;

  for my $part (@parts) {
    next if $part eq '.';  # Skip current directory references
    if ($part eq '..') {
      pop @stack if @stack;  # Go up one directory if possible
    } else {
      push @stack, $part;  # Add the directory to the stack
    }
  }
  return join('/', @stack);
} # canonicalize_path

sub pprint {
  my($tmp)=@_;
  print $tmp;

  if(0) { # leave ANSI for now...
    my $add=0;
    while($tmp=~/(.*?)(\033\[[\d\;]+m)(.*)/sm) {
      $add+=length($2); # if(length($1)<$cols);
      $tmp=$1 . $3;
    }
  }
  $pprint .=$tmp;
} # pprint


=for spare

git-meta.pl - solution for preserving all the correct file dates, times, ownership, and access permissions in git, and feature to prepare new git projects using your own machines (instead of a cloud or github)

Note-to-self: remember to do this before push:-

	pod2markdown git-meta.pl README.md 


auto-extract branch handling...
git fetch;git reset --hard `git rev-parse origin/HEAD`; # does not run hooks
# git pull won't run - already latest

=cut
