<?php

namespace FIN_CLI;

use FIN_CLI;

trait ParsePluginNameInput {

	/**
	 * If have optional args ([<plugin>...]) and an all option, then check have something to do.
	 *
	 * @param array  $args Passed-in arguments.
	 * @param bool   $all All flag.
	 * @param string $verb Optional. Verb to use. Defaults to 'install'.
	 * @return array Same as $args if not all, otherwise all slugs.
	 * @param string $exclude Comma separated list of plugin slugs.
	 * @throws ExitException If neither plugin name nor --all were provided.
	 */
	protected function check_optional_args_and_all( $args, $all, $verb = 'install', $exclude = null ) {
		if ( $all ) {
			$args = array_map(
				'\FIN_CLI\Utils\get_plugin_name',
				array_keys( $this->get_all_plugins() )
			);
		}

		if ( $all && $exclude ) {
			$exclude_list = explode( ',', trim( $exclude, ',' ) );
			$args         = array_filter(
				$args,
				static function ( $slug ) use ( $exclude_list ) {
					return ! in_array( $slug, $exclude_list, true );
				}
			);
		}

		if ( empty( $args ) ) {
			if ( ! $all ) {
				FIN_CLI::error( 'Please specify one or more plugins, or use --all.' );
			}

			$past_tense_verb = Utils\past_tense_verb( $verb );
			FIN_CLI::success( "No plugins {$past_tense_verb}." ); // Don't error if --all given for BC.
		}

		return $args;
	}

	/**
	 * Gets all available plugins.
	 *
	 * Uses the same filter core uses in plugins.php to determine which plugins
	 * should be available to manage through the FIN_Plugins_List_Table class.
	 *
	 * @return array
	 */
	private function get_all_plugins() {
		// phpcs:ignore FinPress.NamingConventions.PrefixAllGlobals.NonPrefixedHooknameFound -- Calling native FinPress hook.
		return apply_filters( 'all_plugins', get_plugins() );
	}
}
