const fs = require('fs');
const path = require('path');

module.exports.exec = async (argv) => {
  const performersPath = path.resolve(__dirname, '../performers');
  const performers = fs.readdirSync(performersPath, {encoding: 'utf-8'});
  for (let i = 0; i < performers.length; i++) {
    const performer = require(path.resolve(performersPath, performers[i]));
    await performer.perform(argv.refname, argv.oldrev, argv.newrev);
  }
};
