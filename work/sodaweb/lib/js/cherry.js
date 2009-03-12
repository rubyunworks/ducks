// Cherry Framework.
//
// Supply +cherryRoutes+ and away she goes!

var cherryFramework = {

    behaviors_location: 'behaviors/',

    templates_location: '',

    routes_location: '',

    feed_location: '',

    routeName: function() {
        var route = presentUri().query;
        if(route == ''){ route = 'index' }
        return route;
    },

    route: function() {
        return cherryRoutes[this.routeName()];
    },

    //routeFile: function() {
    //  return(this.routes_location + this.routeName() + '.json');
    //}

    // Start this cherry site.
    //
    start: function() {
        var route = this.route();

        // javascript (master) behavior
        //if (route.actions.behavior) {
        //    $.getScript(route.actions.behavior);
        //};

        //$('title').append(route.title)  // proper way to inser this?
        document.title = route.title;

        // dynamic css
        $('head').append('<link REL="stylesheet" HREF="cherry/css/clean.css" TYPE="text/css">');
        for(i in route.view.styles) {
            $('head').append('<link REL="stylesheet" HREF="' + route.view.styles[i] + '" TYPE="text/css">');
        };

        // load template
        $('body').load(cherryFramework.templates_location + route.view.template);

        // apply behaviors
        for(behavior in route.action.behaviors) {
            $.cherry_ajax(cherryFramework.behaviors_location + route.action.behaviors[behavior]);
        };

        // apply data feeds
        for(feed in route.feeds) {
            $.cherry_ajax(cherryFramework.feed_location + route.feeds[feed]);
        };
    }
};
