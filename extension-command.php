<?php

if ( ! class_exists( 'FIN_CLI' ) ) {
	return;
}

$fincli_extension_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fincli_extension_autoloader ) ) {
	require_once $fincli_extension_autoloader;
}

$fincli_extension_requires_fin_5_5 = [
	'before_invoke' => static function () {
		if ( FIN_CLI\Utils\fin_version_compare( '5.5', '<' ) ) {
			FIN_CLI::error( 'Requires FinPress 5.5 or greater.' );
		}
	},
];

FIN_CLI::add_command( 'plugin', 'Plugin_Command' );
FIN_CLI::add_command( 'plugin auto-updates', 'Plugin_AutoUpdates_Command', $fincli_extension_requires_fin_5_5 );
FIN_CLI::add_command( 'theme', 'Theme_Command' );
FIN_CLI::add_command( 'theme auto-updates', 'Theme_AutoUpdates_Command', $fincli_extension_requires_fin_5_5 );
FIN_CLI::add_command( 'theme mod', 'Theme_Mod_Command' );
