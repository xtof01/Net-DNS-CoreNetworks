package Net::DNS::CoreNetworks::Zone;

use strict;
use warnings;

our $VERSION = '0.001';

use JSON::MaybeXS;


sub new {
    my $class = shift;
    my ($client, $name) = @_;
    my $self = bless {
        client => $client,
        name => $name,
    }, $class;
    return $self;
}

sub info {
    my $self = shift;
    my $url = '/dnszones/' . $self->{name};
    my $resp = $self->{client}->_get($url);

    if ($resp->{success}) {
        if ($resp->{headers}->{'content-type'} =~ m!application/json!) {
            my $data = decode_json($resp->{content});
            return wantarray ? @$data : $data;
        }
    }
}

sub add {
    my $self = shift;
    my ($name, $ttl, $type, $data) = @_;
    my $url = '/dnszones/' . $self->{name} . '/records/';
    my $json = encode_json({ name => $name, ttl => $ttl, type => $type, data => $data });
    my $resp = $self->{client}->_post($url, $json);

    if ($resp->{success}) {
        return $resp->{reason};
    }
    return undef;
}

sub remove {
    my $self = shift;
    my ($name, $ttl, $type, $data) = @_;
    my $url = '/dnszones/' . $self->{name} . '/records/delete';
    my $filter = { name => $name, ttl => $ttl, type => $type, data => $data };
    while (my ($key, $value) = each %$filter) {
        delete $filter->{$key} unless defined($value);
    }
    my $json = encode_json($filter);
    my $resp = $self->{client}->_post($url, $json);

    if ($resp->{success}) {
        return $resp->{reason};
    }
    return undef;
}

sub commit {
    my $self = shift;
    my $url = '/dnszones/' . $self->{name} . '/records/commit';
    my $resp = $self->{client}->_post($url);

    if ($resp->{success}) {
        return $resp->{reason};
    }
    return undef;
}

1;
