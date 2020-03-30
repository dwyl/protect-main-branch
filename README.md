<div align="center">

# Protect Master Branch

[![Build Status](https://img.shields.io/travis/dwyl/protect-master-branch/master.svg?style=flat-square)](https://travis-ci.org/dwyl/protect-master-branch)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/protect-master-branch/master.svg?style=flat-square)](http://codecov.io/github/dwyl/protect-master-branch?branch=master)
[![HitCount](http://hits.dwyl.com/dwyl/protect-master-branch.svg)](http://hits.dwyl.com/dwyl/protect-master-branch)

</div>

## _Why?_

If you have an organisation
with a lot of collaborators
who all have write access to your repositories,
it's a _really_ good idea
to protect `master` from accidental deletion.


## _What?_

If anyone in your organisation can
`git push master --force`
and _destroy_ all history of the repository,
someone could either accidentally or maliciously
burn down your house!

<div align="center">
    <a href="https://www.google.com/search?q=git+push+master+--force&source=lnms&tbm=isch">
        <img src="https://user-images.githubusercontent.com/194400/66544431-049f0a00-eb30-11e9-8ccc-696d2016a05b.png">
    </a>
</div>
<br />

> **Note**: we didn't create this
[meme](https://www.google.com/search?q=git+push+master+--force&tbm=isch),
force-pushing to `master` is widely known to be destructive
and potentially catastrophic.


## _Who?_

This is relevant to organisations/people
that have a _lot_ of GitHub repositories
and want to protect them from accidental
(_or malicious_) destruction.


## _How_?

### Requirements

[Elixir 1.5](http://elixir-lang.github.io/install.html)

Github API Token:
You'll need a personal access token
from someone with admin rights
to all of the repos you want to protect.
To generate a token,
follow this guide from Github Help:
https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line

Your token only requires **repo** access:  
<img width="500" alt="Repo access options for personal token"
src="https://user-images.githubusercontent.com/8939909/32742752-3a9f68d2-c8a2-11e7-9251-e022095f6ee0.png">  

Don't give it more permissions than it needs.
See: https://en.wikipedia.org/wiki/Principle_of_least_privilege

Once you've generated your access token,
make it available as an environment variable by running:

```
export GITHUB_ACCESS_TOKEN=<your-personal-access-token>
```

> Note: we place this export statement
in an
[`.env`](https://github.com/dwyl/learn-environment-variables#3-use-a-env-file-locally-which-you-can-gitignore)
file to avoid losing the variable when the terminal session ends.




### Usage

You'll first need to clone this repo:  

```sh
git clone git@github.com:dwyl/protect-master-branch.git
```

Then `cd protect-master-branch`

Then run:  
```sh
mix escript.build
```

This will create a file called `protect`.

Use the script as follows:  
```
./protect --org <name> --rules <path/to/file.json>
OR
./protect --user <name> --rules <path/to/file.json>

Options:
  --org: Name of the organisation that owns the repos you want to protect.
  --user: Name of the user who owns the repos you want to protect.
  --rules: A path to a json file where you have defined the rules you want to
           apply to the master branch of all your repos.
```

Either user _or_ org should be passed as an option, never both.

Example:
```
./protect --org dwyl --rules rules.json
```

You should expect to see output similar to the following:

```
"/repos/dwyl/learn-vim/branches/master/protection"
"/repos/dwyl/app/branches/master/protection"
"/repos/dwyl/learn-heroku/branches/master/protection"
"/repos/dwyl/learn-amazon-web-services/branches/master/protection"
...
"/repos/dwyl/auth-mvp/branches/master/protection"
"/repos/dwyl/flutter-counter-example/branches/master/protection"
Error 404: why
Error 404: learn-WebAssembly
  318 branches succesfully protected
  2 branches errored
```

Repos will appear in the output in age order.
(_oldest repos first_)


 See [Github API docs](https://developer.github.com/v3/repos/branches/#update-branch-protection) for full details of the protection rules available, and [our rules file](https://github.com/dwyl/protect-master-branch/blob/master/rules.json) for an example.
