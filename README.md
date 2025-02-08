# git-meta

Easy solution to:

- Automatically preserve all the correct dates, times (including zones and microseconds), ownership, and access permissions on all your files in git
- Quickly set up a new non-cloud, non-github private git project on your own servers, which you and/or your team can work with from any number of other machines
- Optionally have your server automatically extract your files and keep them up-to-date (for example: so you can deploy to your webserver's live environment with "git push"

# Quick-Start

1. install it:

            git clone https://github.com/gitcnd/git-meta.git
            sudo cp -a git-meta/git-meta.pl /usr/local/bin/

then either

- set up to use it:

            cd my_existing_repo
            git-meta.pl -setup -l /usr/local/bin/git-meta.pl

or

- create a brand-new local project

            git-meta.pl -newgit -l . MyProject /var/www/html/MyProject-optional-autoextract-folder

# Synopsis

## Mode 1 - preserving dates/times/ownership/permissions etc:

        # creates the pre-commit and post-merge hooks (see below)
        cd ~/myrepo
        git-meta.pl -setup -l /usr/local/bin/git-meta.pl
        -or-
        git-meta.pl -setup


        # optional manual "save" usage (Typically this is called from the pre-commit) to preserve dates/times/ownership/permissions
        cd ~/myrepo
        git-meta.pl -save [optional list of files]


        # optional manual "restore" usage (Typically called from post-merge)
        cd ~/myrepo
        git-meta.pl -restore [optional list of files]

### How Mode 1 works:

A git pre-commit hook is added, which creats the file ".git-meta" in your project and adds this to your commit.  
.git-meta contains all the real file metadata in your project (correct dates and times, ownerships, permissions, etc)

A git post-merge hook is added, which restores all the correct information from the .git-meta file

## Mode 2 - Automatically set up a new full-featued non-cloud repo on your own machine/servers

        # Create a new local master repo, which preserves dates etc, and also automatically extracts files every time you push (handy for automatically deploying to a live web server through git-push for example)
        # (handy for working on your own private mahcines, such as when maintaining web servers.)
        perl git-meta.pl -master_location=/usr/local/apache2/gitblobs -newgit mynewproject /usr/local/apache2/htdocs/mynewproject

        # creates a working 3-folder shared dev environment for production web server site
        # Omitting "-master_location" will default to ~/gitblobs
        # Uses `sudo chmod g+s` to allow for multi-user environemnts based on unix group permissions.

Note: adds the file .git-meta to your project

### How Mode 2 works:

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

be sure to run that \`git-meta.pl -setup -l .\` command: "git clone" does not automatically clone the hooks you need which are required to keep your dates/times/etc preserved.

## Options

        -f              # Specify the meta filename to use ( defaults to .git-meta )
        -save           # Save into the .git-meta. Saves all files if none are provided
        -restore        # Restore from the .git-meta. Restores all files if none are provided
        -setup          # create the necessary pre-commit and post-merge files to activate this solution in your repo
        -strict         # Stop with errors instead of assume what the user wants (partially implimented)
        -dryrun         # Show what would be done, without doing it (partially implimented)
        -l              # use a symlink when doing setup, for pre-commit and post-merge (e.g. -l /usr/local/bin/git-meta.pl) - otherwise - copies the file there.
        -newgit         # creates a working 3-folder shared dev environment for production web (or other) server site
        -master_location# Where to store the master filess (defaults to ~/gitblobs/)
        -group          # which groupname do all developers belong to
        -debug          # print everything going on

## .git-meta file format

        # lines starting with # are comments
        octal file mode, owner, group, mtime, atime, spare1, spare2, filename

# FILENAMES

.git/hooks/pre-commit	- this same perl script, when it has the name "pre-commit" assumes you're running "git-meta.pl -save"
.git/hooks/post-merge	- this same perl script, when it has the name "post-merge" assumes you're running "git-meta.pl -restore"
newgit.pl		- this same perl script, when it has the name "newgit.pl", behaves as if the -newgit option was supplied - see below.

newgit.pl - create a new, optionally auto-extracting, private git repo, with preservation of file metadata (dates/time, permissions, ownership)
 -or-
git-meta.pl -newgit

# -newgit Synopsis

        newgit.pl gitname [optional-auto-extract-location]
        # creates gitname                               # this is where master files live. Uses $master_location/gitname unless gitname starts with /
        # creates ./gitname                             # this is a local working folder for editing your files etc (you can "git clone" more of these later)
        # maybe creates optional-auto-extract-location  # this is where they'll be auto-extracted (properly includes mv/rm etc) upon all git push operations

        SCREW_UP_DATES=1 newgit.pl gitname [optional-auto-extract-location]
        # same as above, omitting the hooks which preserve dates/permissions/ownership

        DRYRUN=1 newgit.pl gitname [optional-auto-extract-location]
        DRYRUN=1 SCREW_UP_DATES=1 newgit.pl gitname [optional-auto-extract-location]
        # same as either of the above two, but doing nothing (shows what commands will be executed)

## Example

        newgit.pl leoweb ~/leo/public_html

## File location info

        if there's no "/" within "gitname", it will put the files into $master_location/gitname (e.g. ~/gitblobs/gitname ) by default

git-meta.pl - solution for preserving all the correct file dates, times, ownership, and access permissions in git, and feature to prepare new git projects using your own machines (instead of a cloud or github)
