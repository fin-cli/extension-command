<?php

if ( ! class_exists( 'FP_CLI' ) ) {
	return;
}

$fpcli_extension_autoloader = __DIR__ . '/vendor/autoload.php';
if ( file_exists( $fpcli_extension_autoloader ) ) {
	require_once $fpcli_extension_autoloader;
}

$fpcli_extension_requires_fp_5_5 = [
	'before_invoke' => static function () {
		if ( FP_CLI\Utils\fp_version_compare( '5.5', '<' ) ) {
			FP_CLI::error( 'Requires FinPress 5.5 or greater.' );
		}
	},
];

FP_CLI::add_command( 'plugin', 'Plugin_Command' );
FP_CLI::add_command( 'plugin auto-updates', 'Plugin_AutoUpdates_Command', $fpcli_extension_requires_fp_5_5 );
FP_CLI::add_command( 'theme', 'Theme_Command' );
FP_CLI::add_command( 'theme auto-updates', 'Theme_AutoUpdates_Command', $fpcli_extension_requires_fp_5_5 );
FP_CLI::add_command( 'theme mod', 'Theme_Mod_Command' );
