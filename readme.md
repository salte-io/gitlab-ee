# Overview
Gitlab Enterprise Edition including the NodeJS runtime and a framework for incorporating Git server hooks written in NodeJS.  To include additional hooks simply add a JavaScript module, known as a performer, to the application/main/performers directory.  Of course, it would also be preferred if you added a corresponding test to the application/test/performers directory :-)

The following section describes the contract that all performers must adhere to.

# Performers
## Code Sample
```javascript
const simpleGit = require('simple-git');
const yaml = require('yaml');

const git = simpleGit();

module.exports.perform = (refname, oldrev, newrev) => {
  return git.catFile(['blob', `${newrev}:.gitlab-ci.yml`]).then((contents) => {
    const gitlabCiFile = yaml.parse(contents);
    for (const [key] of Object.entries(gitlabCiFile)) {
      if (gitlabCiFile[key]['tags'] && gitlabCiFile[key]['tags'].includes('production')) {
        if (!gitlabCiFile[key]['only'] ||
            gitlabCiFile[key]['only'].length > 1 ||
            gitlabCiFile[key]['only'][0] !== 'production') {
          throw new Error('GL-HOOK-ERR: Only the production branch can target the production Gitlab runner.');
        }
      }
    }
    return true;
  });
};
```
## Narrative
### Pseudocode
1. Get the contents of the .gitlab-ci.yml file for the current commit.
2. Convert the YAML contents into a JSON object.
3. Iterate through over all top-level objects.
4. Look for top-level objects containing tags that include production.
5. If you find an entry with a production tag that does not include an "only" constraint with a single entry for the production branch then throw an error.
### Contract Obligations
* The module may accept the branch name (refname), previous commit (oldrrev), and new commit (newrev) as input parameters.
* The module must return a JavaScript promise.
* To indicate failure, the module should throw an error with the message prefixed by "GL-HOOK-ERR: ".
