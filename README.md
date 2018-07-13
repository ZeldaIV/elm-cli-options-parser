## Some Inspiration for this package

* http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html.
* https://pythonconquerstheuniverse.wordpress.com/2010/07/25/command-line-syntax-some-basic-concepts/
* https://devcenter.heroku.com/articles/cli-style-guide
* http://docopt.org/

## Feedback Wanted On

### Command.withoutRestArgs/withRestArgs

This is needed to enforce the constraint that
this needs to be called once I have the number of arguments that came before it...
so that they can be dropped from the rest args.

### expectFlag is on Command not Spec

Right now, I need that because it doesn't change the value of the pipeline... is there a simple way to change that?

### Feedback wanted

Is it confusing to go between Command. and Spec.?
