---
title: Failed Tests
assignees: ricardojosegomezulmke
labels: bug
---

* template variables: https://github.com/JasonEtco/actions-toolkit#toolscontext
* dates with Moment.js: https://momentjs.com/docs/#/displaying/

Tests failed.

- who dunnit: {{ payload.sender.login }}
- when: {{ date | date('dddd, MMMM Do YYYY, HH:mm:ss') }}
- ref: {{ github.ref }}
- ref: {{ env.REF }}
- workflow: {{ tools.context.workflow }}
- repo: {{ tools.context.repo }}


---
The End.