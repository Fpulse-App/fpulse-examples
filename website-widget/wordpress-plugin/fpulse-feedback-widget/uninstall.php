<?php
/**
 * Remove the plugin's settings when it is deleted.
 */

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

delete_option( 'fpulse_feedback_widget' );
