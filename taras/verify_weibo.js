var casper = require('casper').create({
    loadImages: false,
    pageSettings: {
        userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/536.4 (KHTML, like Gecko) Chrome/19.0.1072.0 Safari/536.4"
    },
    onAlert: function(obj, msg) {
        console.log("got alert:(" + msg + ")");
    }
});

var url = casper.cli.get(0);
var username = casper.cli.get("user");
var password = casper.cli.get("passwd");
var type = casper.cli.get("type");


casper.start(url, function() {
    this.echo(this.getTitle());

    if (type == "qq") {
        this.fill("#loginform", {
            'u': username,
            'p': password
        }, false);

    } else if (type == "sina") {
        this.echo("filling sina form");
        this.fill("form[action='authorize']", {
            'userId': username,
            'passwd': password
        }, false);

    }
});

casper.then(function() {
    if (type == "qq") {
        this.click("#login_btn");
    } else if (type == "sina") {
        this.echo("clicking sina submit");
        this.click("a#sub");
    }
});

casper.then(function() {
    this.wait(5000, function() {
        this.echo("title: " + this.getTitle());
        this.echo("current url: " + this.getCurrentUrl());
        if (type == "qq") {
            this.echo('code:' + this.fetchText("#vCode"));
        } else if (type == "sina") {
            this.echo('code:' + this.fetchText("span.fb"));
        }
    });
});

casper.echo("starting casper, url:" + url + " user: " + username + " password: " + password);

casper.run(function() {
    this.echo("verify_weibo.js finished");
    casper.exit();
});