# Mode: perl; tab-width: 8; indent-tabs-mode: nill; perl-basic-offset: 8 
# We need to work more in the upload names - acs
# Alvaro del Castillo - Ándago (c) 2002 under GPL

package Slash::Doc;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);

use Slash;
use Slash::Utility;
use Slash::DB::Utility;
use vars qw($VERSION @ISA);

@ISA = qw(Slash::DB::Utility);
$VERSION = '0.01';

sub new {	
	my($class, $user) = @_;
	my $self = {};
	bless($self, $class);
	$self->{virtual_user} = $user;
	$self->sqlConnect();
	createEnvironment($user);
	return $self;
}

sub new_doc {
	my ($self, $doc_info, $section_id) = @_;
	my $form   = getCurrentForm();
	my $upload = $form->{query_apache}->upload;

	# We need to inform here the user
	return if ! $upload;
	return if ! $upload->filename;

	$doc_info->{file} = $self->_create_file_upload ($upload, $section_id);
	$self->sqlInsert("documents",$doc_info);
}

sub new_image {
	my ($self) = @_;
	my $form   = getCurrentForm();
	my $upload = $form->{query_apache}->upload;

	# We need to inform here the user
	return if ! $upload;
	return if ! $upload->filename;

	my $file_save = $self->_create_file_upload ($upload);
	my $file_url = $self->get_upload_url ($upload->filename);
	return $file_url;
}

sub get_upload_name {
        my ($self, $filename, $section) = @_;
	my $constants = getCurrentStatic();
	my $dir = "imagenes";
	$dir = $section if $section;
	
	my $file_save = $constants->{basedir}."/$dir/$filename";
	return $file_save;
}

sub get_upload_url {
        my ($self, $filename, $section) = @_;
	my $constants = getCurrentStatic();
	my $dir = "imagenes";
	$dir = $section if $section;
	
	my $file_save = "http:".$constants->{rootdir}."/$dir/$filename";
	return $file_save;
}

sub _create_file_upload {
        my ($self, $upload, $section_id) = @_;
	my $slashdb = getCurrentDB();
	my $section;
	
	return if ! $upload->filename;

	if ($section_id) {
	    ($section) = $slashdb->sqlSelect ("section","sections","id='$section_id'");
	}
	
	my $buffer_size = 1024;
	my $buffer;
	my $filename = $upload->filename;
	my $file = $upload->fh;
        my $size = $upload->size;
	my $file_save = $self->get_upload_name($filename, $section);

	open(FILE, ">$file_save");
        while (read $file, $buffer, $buffer_size) {
                print FILE $buffer;
        }
        close FILE;
	return $file_save;
}

sub get_doc {
	my ($self, $document_id) = @_;
	my $answer = $self->sqlSelectHashref (
					      '*',
					      'documents', "document_id='$document_id'"
					      );
	return $answer;				    
}

sub get_docs {
	my ($self) = @_;
	my $answer;
	$answer = $self->sqlSelectAllHashrefArray (
						   'documents.name as name, file, size, projects.name as project',
						   'documents, projects', 'documents.project_id = projects.project_id', 'ORDER BY sello desc'
						   );	
	return $answer;				    
}

sub project_remove_doc {
    my ($self, $document_id, $uid) = @_;
    my $slashdb = getCurrentDB();
    $slashdb->sqlDo("DELETE FROM documents where uid='$uid' and project_id ='$document_id'");
    # we want to remove also the file?
}

1;
__END__


=head1 NAME

Slash::Doc - Perl extension for a system document manager for slashcode

=head1 SYNOPSIS

  use Slash::Doc;


=head1 DESCRIPTION

A plugin for slashcode to manage a project documentation


=head1 AUTHOR

Alvaro del Castillo, acs@andago.com

=head1 SEE ALSO

perl(1).

=cut
