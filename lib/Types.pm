package Types;

use v5.38;

use Type::Libraries;
use Type::Tiny;

Type::Libraries->setup_class(
	__PACKAGE__,
	qw(
		Types::Standard
		Types::Common::Numeric
		Types::Common::String
	),
);

