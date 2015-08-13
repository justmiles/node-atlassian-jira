# node-atlassian-jira
Node.js client library to interact with Atlassian Jira

## Installation

If you have the node package manager, npm, installed:

```shell
npm install --save atlassian-jira
```

## Getting Started

Example:

```javascript
var jira = require('atlassian-jira');

jira.username = 'your_username';
jira.password = 'your_password';
jira.host = 'jira_host.com';
jira.context = '/jira'; // optional 

jira.simpleSearch('test', null, function(err, res) {
  if (err != null) {
    console.log(err);
  }
  if (res != null) {
    return console.log(res);
  }
});
```

Refer to https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis for additional documentation.