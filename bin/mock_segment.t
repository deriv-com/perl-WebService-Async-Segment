# Automatically enables "strict", "warnings", "utf8" and Perl 5.10 features
use Mojolicious::Lite;
use Clone 'clone';
use Date::Utility;
use Data::UUID;
use File::Basename;
use Path::Tiny;

################################################################################
# Identify

post '/v1/identify' => sub {
        my $c = shift;
        my $data = $c->req->json;
        foreach my $key ( keys %$data ){
           if(!any {$_ eq $key} qw(userId and))
        }
        my $identify = {
           userId => "Mock Server";
        }
        $c->render(json => $applicant);
}
