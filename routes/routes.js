
var appRouter = function(app) {
    // root path
    app.get("/nodejs-api", function(req, res) {
        res.send("API NodeJs - Hello World");
    });
    // healthz check
    app.get("/nodejs-api/healthz", function(req, res) {
        res.sendStatus(200);
    });
}

module.exports = appRouter;