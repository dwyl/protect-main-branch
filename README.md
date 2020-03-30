# Protect Master Branch

# _Why?_


# _What?_


# _Who?_

This is relevant to organisations/people
that have a _lot_ of GitHub repositories
and want to protect them from accidental
(_or malicious_) destruction.


# _How_?

## Requirements

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




## Use

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

 See [Github API docs](https://developer.github.com/v3/repos/branches/#update-branch-protection) for full details of the protection rules available, and [our rules file](https://github.com/dwyl/protect-master-branch/blob/master/rules.json) for an example.
