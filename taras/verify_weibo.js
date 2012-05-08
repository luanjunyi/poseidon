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
    // this.echo(this.fetchText("pre"));
    // casper.exit();

    this.echo("base url, page title:" + this.getTitle());

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
        this.echo("clicking qq submit");
        this.click("#login_btn");
    } else if (type == "sina") {
        this.echo("clicking sina submit");
        this.click("a#sub");
    }
});

casper.then(function() {
    this.wait(5000, function() {
        this.echo("final title: " + this.getTitle());
        this.echo("final url: " + this.getCurrentUrl());
        var code = "";
        if (type == "qq") {
            code = this.fetchText("#vCode");
        } else if (type == "sina") {
            code = this.fetchText("span.fb");
        }
        if (code === "") {
            var dump_path = "auth_dump/" + username + "." + password + ".png";
            this.echo("no verification code is found, dump webpage to " + dump_path);
            this.capture(dump_path);
        }
        this.echo ('code:' + code);
    });
});

casper.echo("starting casper, url:" + url + " user: " + username + " password: " + password);

casper.run(function() {
    this.echo("verify_weibo.js finished");
    casper.exit();
});
