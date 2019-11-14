# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Clone 'clone';
use Date::Utility;
use Data::UUID;
use File::Basename;
use Path::Tiny;
use Try::Tiny;

################################################################################
# Identify

post '/v1/identify' => sub {
    my $c = shift;
    try{
        my $data = $c->req->json;
        $c->render(status => 200, json   => {success => 'true'});
    }
    catch{
        $c->render(status => 400);
    };
};

################################################################################
## Track
post '/v1/track' => sub {
    my $c = shift;
    try{
        my $data = $c->req->json;
        $c->render(status => 200, json   => {success => 'true'});
    }
    catch{
        $c->render(status => 400);
    };
};
# Start the Mojolicious command system
app->start;
