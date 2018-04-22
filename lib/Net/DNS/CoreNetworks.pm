package Net::DNS::CoreNetworks;

use strict;
use warnings;

our $VERSION = '0.001';

use HTTP::Tiny;
use JSON::MaybeXS;

use Net::DNS::CoreNetworks::Zone;

my $baseurl = 'https://beta.api.core-networks.de';

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->{ua} = HTTP::Tiny->new(agent => __PACKAGE__, verify_SSL => 1);
    return $self;
}

sub login {
    my $self = shift;
    my ($username, $password) = @_;
    my $url = '/auth/token';
    my $json = encode_json({ login => $username, password => $password });
    my $resp = $self->_post($url, $json);

    if ($resp->{success}) {
        if ($resp->{headers}->{'content-type'} =~ m!application/json!) {
            my $data = decode_json($resp->{content});
            $self->{token} = $data->{token};
            return $resp->{reason};
        }
    }
    return undef;
}

sub zones {
    my $self = shift;
    my $url = '/dnszones/';
    my $resp = $self->_get($url);

    if ($resp->{success}) {
        if ($resp->{headers}->{'content-type'} =~ m!application/json!) {
            my $data = decode_json($resp->{content});
            return wantarray ? @$data : $data;
        }
    }
}

sub zone {
    my $self = shift;
    my ($name) = @_;
    my $zone = Net::DNS::CoreNetworks::Zone->new($self, $name);
    return $zone;
}

sub _get {
    my $self = shift;
    return $self->_request('GET', @_);
}

sub _post {
    my $self = shift;
    return $self->_request('POST', @_);
}

sub _request {
    my $self = shift;
    my ($method, $path, $content) = @_;

    my $url = $baseurl . $path;
    my $options = {};
    if (defined($self->{token})) {
        $options->{headers}->{Authorization} = 'Bearer ' . $self->{token};
    }
    if (defined($content)) {
        $options->{headers}->{'Content-Type'} = 'application/json';
        $options->{content} = $content;
    }
    return $self->{ua}->request($method, $url, $options);
}

1;
