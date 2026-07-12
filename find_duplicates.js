const fs = require('fs');
const c = fs.readFileSync('lib/core/localization/messages.dart', 'utf8');
const lines = c.split('\n');
const keys = ['ja','ko','zh','de','fr','es','pt','ru','it','bn','doi','kok','ms','nl','pl','tr','vi','th','id'];
keys.forEach(k => {
  const h = [];
  lines.forEach((l, i) => {
    if (l.includes("'" + k + "'")) h.push(i + 1);
  });
  if (h.length > 1) console.log(k, h.join(','));
});
