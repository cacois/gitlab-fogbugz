GitLab + Fogbugz
===
(forked and adapted from [github-fogbugz](https://github.com/johnreilly/github-fogbugz/))

This is a simple sinatra application that has three responsibilities:

* Receive and parse the JSON commit info from GitLab's post-receive hooks and send it to FogBugz
* Act as a "gateway" for viewing multiple SCM repositories in FogBugz
* Edit case history per the commit message's instructions.

Prerequisites
---
Gems:

* sinatra
* json
* mocha (for running tests)

Optional:

* [Ragel](http://research.cs.queensu.ca/~thurston/ragel/): for generating the FogBugz message parser. If you install gitlab-fogbugz as a gem, you will *not* need to generate the message parser.
* [GraphViz](http://www.graphviz.org): for generating a graph of the Ragel generated state machine): 

To Install and Run:
---

    # Install the prerequisite gems.
    $ sudo gem install sinatra json
    
    # You need Ragel locally to make this next command work.
    # If you installed gitlab-fogbugz as a gem, you do NOT need to execute this step.
    $ rake ragel:compile 
    
    # Copies the config file examples to ~/.gitlab-fogbugz/config.yml
    $ gitlab-fogbugz
    
    ...edit config.yml (see "configuration" section below)...
    
    $ gitlab-fogbugz-server [-p port] [-e production]

    # Send your developers here so they can authenticate with FogBugz.
    # Each developer must login here before their commit messages
    # will be sent to FogBugz.
    $ http://<gitlab-fogbugz-address>:<port>/login
    
Configuration
---

### GitLab repositories:
Set up your repositories on GitLab to send a post-receive hook to the root url of this sinatra app. Be sure to include the port, if other than 80.

### gitlab-fogbugz-server (this app):
The configuration file holds several variables that you'll need to edit.

* **fb\_main\_url**: The url to your FogBugz's installation.
* **repos**: A list of the SCM repositories that you're using.  Each repo has two urls:
  * *log_url*: The url to the commit log for a specific file 
  * *diff_url*: The url to the specific commit or revision.
* (Currently unsupported: **fb\_submit\_url**: The url to the cvsSubmit.[php|asp] file on your FogBugz server.)

Each repo name must match the the values that are in the *sRepo* field in FogBug's *CVS* table.

### Authenticating:
Each developer must login to FogBugz through this app.  Visit **/login** and follow the instructions.  The act of logging in will create a tokens.yml file in the app's config directory, chmod'ed 0600.  **Note**: gitlab-fogbugz-server expects the developer's E-Mail addresses to match in both GitLab and FogBugz.

### FogBugz:  
You'll need to do some configuration in FogBugz as well.  As the FogBugz admin, edit your site settings, and in the source control urls for logs and diffs, enter:

* Logs: "http://thisapp:port/repo_url?type=log&repo=^REPO&file=^FILE&r1=^R1&r2=^R2" 
* Diffs: "http://thisapp:port/repo_url?type=diff&repo=^REPO&file=^FILE&r1=^R1&r2=^R2"

The only difference between the two is the "type" parameter.

> I'm not a fan of Fog Creek's [suggested solution](http://www.fogcreek.com/FogBugz/KB/howto/MultipleRepositories-Mult.html) for multiple repositories, as it requires you to copy a new script into the FogBugz website directory. This seems fine, but (as is my understanding) you'll have to copy it over again and again with each FogBugz upgrade because the website directory gets recreated each time. That's why this script also acts as the SCM viewer "gateway."

**Note:** If you've been using FogBugz in the past with only a single repository, odds are your *sRepo* field is empty. Mine was. Be sure that all of the records in FogBugz's *CVS* table have a valid *sRepo* that matches up to a repo specified in the config file.

Other Notes
---
(NOTE: This section currently does not apply: as of gitlab 2.6 the post-receive hook does not receive the fle names, [see the request at github](https://github.com/gitlabhq/gitlabhq/issues/747) ).

When parsing out the file names from gitlab commits, I've tacked on the branch that the file lives on.  So in FogBugz you'll see files like "master/myfile.rb".  This is simply because my team does the "release on a branch" thing (aka [Release Line](http://www.scmpatterns.com/book/pattern-summary.html)), and I like to see which branch certain bugs were fixed on.  Feel free to modify this behavior.

Caveats
---
(NOTE: This section currently does not apply: as of gitlab 2.6 the post-receive hook does not receive the fle names, [see the request at github](https://github.com/gitlabhq/gitlabhq/issues/747) ).

It's fairly obvious that FogBugz was written for a more traditional CVS/SVN SCM system in mind. As such, the commit list display doesn't really jive with git:

![Messy Commits List in FogBugz](http://img.skitch.com/20080424-kb6kujbfd224436pqgnhgj33sk.jpg)

This is in FogBugz 6.1.23.  I've got a [thread started](http://support.fogcreek.com/default.asp?fogbugz.4.24526.0) on their forum asking for this to be cleaned up a bit. We'll see if it gets better in future releases.

Thanks
---
All praises go to John Reilly et al for their work on [github-fogbugz](https://github.com/johnreilly/github-fogbugz), I simply renamed and adjusted a few things to get it working with GitLab.

Major thanks to [François Beausoleil](http://github.com/francois) for turning this project into something much greater than I had dreamed of.

Inspired by [github-campfire](http://github.com/jnewland/github-campfire) by [jnewland](http://github.com/jnewland) and
[github-twitter](http://github.com/jnunemaker/github-twitter) by [jnunemaker](http://github.com/jnunemaker). 

License
---
MIT.  See LICENSE file.
