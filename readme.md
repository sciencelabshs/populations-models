# [Populations.js Models](https://github.com/concord-consortium/populations-models)

This repository hosts a collection of models built using [populations.js](https://github.com/concord-consortium/populations.js).

To view the models running, see
[http://concord-consortium.github.io/populations-models/](http://concord-consortium.github.io/populations-models/)

## Running Locally

This project is built using Brunch.io, which compiles the CoffeeScript,
stylesheets, and other assets.

### Dependencies

* [Node](http://nodejs.org/) `brew install node`
* [Bower](http://bower.io/) `npm install -g bower`

### Setup Brunch and Project Libraries

You'll need to install the plugins required for the brunch project, as well
as libraries the project depends on.

```
  npm install
  bower install
```

### Starting the Server

Run this command:

```
  npm start
```

Now open http://localhost:3333. Whenever you make a change to a file the
browser will be automatically refreshed.

Your files will automatically be built into the /public directory
whenever they change.

You can also just run `brunch build` to simply build the files into /public without starting
the server.

## Libraries and Frameworks Used

* [populations.js](https://github.com/concord-consortium/populations.js) - Population-level simulator
* [CoffeeScript](http://coffeescript.org/) - Making JavaScript suck less.
* [Brunch](http://brunch.io) - Asset Compilation
* [Node](http://nodejs.org/) - For Brunch

## License

Populations-Models is Copyright 2014 (c) by the Concord Consortium and is distributed under
any of the following licenses:

- [Simplified BSD](http://www.opensource.org/licenses/BSD-2-Clause),
- [MIT](http://www.opensource.org/licenses/MIT), or
- [Apache 2.0](http://www.opensource.org/licenses/Apache-2.0).

Populations.js is Copyright 2014 (c) by the Concord Consortium and is distributed under
any of the following licenses:

- [Simplified BSD](http://www.opensource.org/licenses/BSD-2-Clause),
- [MIT](http://www.opensource.org/licenses/MIT), or
- [Apache 2.0](http://www.opensource.org/licenses/Apache-2.0).
