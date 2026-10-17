<?php
/**
 * Plugin Name:       F-Pulse Feedback Widget
 * Plugin URI:        https://fpulse.app/feedback-widget/wordpress
 * Description:       Adds the F-Pulse App feedback button to your site. Visitors rate their experience and leave a comment; you see it all in your F-Pulse dashboard.
 * Version:           1.0.0
 * Requires at least: 6.3
 * Requires PHP:      7.4
 * Author:            F-Pulse App
 * Author URI:        https://fpulse.app
 * License:           GPLv2 or later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       fpulse-feedback-widget
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

define( 'FPULSE_FW_OPTION', 'fpulse_feedback_widget' );
define( 'FPULSE_FW_SCRIPT_BASE', 'https://fpulse.app/w/' );

/**
 * Saved settings merged with defaults.
 *
 * @return array{widget_id: string, enabled: bool, environment: string, hide_for_admins: bool}
 */
function fpulse_fw_settings() {
	$defaults = array(
		'widget_id'       => '',
		'enabled'         => true,
		'environment'     => 'production',
		'hide_for_admins' => false,
	);
	$saved    = get_option( FPULSE_FW_OPTION, array() );
	return wp_parse_args( is_array( $saved ) ? $saved : array(), $defaults );
}

/**
 * Accepts a widget ID (fp_xxxx), a script URL or the whole snippet and returns just the ID.
 *
 * @param string $value What the user pasted.
 * @return string The widget ID, or '' when none was found.
 */
function fpulse_fw_extract_widget_id( $value ) {
	if ( preg_match( '/\b(fp_[A-Za-z0-9_-]{4,64})\b/', (string) $value, $match ) ) {
		return $match[1];
	}
	return '';
}

/**
 * Load the widget on the public site.
 */
function fpulse_fw_enqueue() {
	if ( is_admin() ) {
		return;
	}
	$settings = fpulse_fw_settings();
	if ( ! $settings['enabled'] || '' === $settings['widget_id'] ) {
		return;
	}
	if ( $settings['hide_for_admins'] && current_user_can( 'manage_options' ) ) {
		return;
	}

	$src = FPULSE_FW_SCRIPT_BASE . rawurlencode( $settings['widget_id'] ) . '.js';
	if ( 'development' === $settings['environment'] ) {
		$src = add_query_arg( 'env', 'dev', $src );
	}

	// No version argument: the widget is updated on the F-Pulse side.
	wp_enqueue_script(
		'fpulse-feedback-widget',
		$src,
		array(),
		null, // phpcs:ignore WordPress.WP.EnqueuedResourceParameters.MissingVersion
		array(
			'in_footer' => true,
			'strategy'  => 'defer',
		)
	);
}
add_action( 'wp_enqueue_scripts', 'fpulse_fw_enqueue' );

/**
 * Settings page under Settings > F-Pulse Feedback.
 */
function fpulse_fw_admin_menu() {
	add_options_page(
		__( 'F-Pulse Feedback Widget', 'fpulse-feedback-widget' ),
		__( 'F-Pulse Feedback', 'fpulse-feedback-widget' ),
		'manage_options',
		'fpulse-feedback-widget',
		'fpulse_fw_render_settings_page'
	);
}
add_action( 'admin_menu', 'fpulse_fw_admin_menu' );

/**
 * Register the option with a sanitizer.
 */
function fpulse_fw_register_settings() {
	register_setting(
		'fpulse_fw',
		FPULSE_FW_OPTION,
		array(
			'type'              => 'array',
			'sanitize_callback' => 'fpulse_fw_sanitize',
			'default'           => array(),
		)
	);
}
add_action( 'admin_init', 'fpulse_fw_register_settings' );

/**
 * Clean the submitted settings.
 *
 * @param mixed $input Raw form values.
 * @return array
 */
function fpulse_fw_sanitize( $input ) {
	$input = is_array( $input ) ? $input : array();
	$raw   = isset( $input['widget_id'] ) ? (string) $input['widget_id'] : '';
	$id    = fpulse_fw_extract_widget_id( $raw );

	if ( '' !== trim( $raw ) && '' === $id ) {
		add_settings_error(
			FPULSE_FW_OPTION,
			'fpulse_fw_bad_id',
			__( 'That does not look like an F-Pulse widget ID. Copy the snippet or the ID (it starts with fp_) from the Widget page of your F-Pulse dashboard.', 'fpulse-feedback-widget' )
		);
	}

	return array(
		'widget_id'       => $id,
		'enabled'         => ! empty( $input['enabled'] ),
		'environment'     => ( isset( $input['environment'] ) && 'development' === $input['environment'] ) ? 'development' : 'production',
		'hide_for_admins' => ! empty( $input['hide_for_admins'] ),
	);
}

/**
 * Settings page markup.
 */
function fpulse_fw_render_settings_page() {
	if ( ! current_user_can( 'manage_options' ) ) {
		return;
	}
	$settings = fpulse_fw_settings();
	$name     = FPULSE_FW_OPTION;
	?>
	<div class="wrap">
		<h1><?php esc_html_e( 'F-Pulse Feedback Widget', 'fpulse-feedback-widget' ); ?></h1>

		<?php if ( '' === $settings['widget_id'] ) : ?>
			<div class="notice notice-info inline">
				<p>
					<?php esc_html_e( 'Get your widget ID in two minutes:', 'fpulse-feedback-widget' ); ?>
					<a href="https://fpulse.app/auth/register?utm_source=wordpress&amp;utm_medium=plugin&amp;utm_campaign=settings" target="_blank" rel="noopener noreferrer"><?php esc_html_e( 'create a free F-Pulse account', 'fpulse-feedback-widget' ); ?></a>,
					<?php esc_html_e( 'turn on the widget on the Widget page and copy the snippet.', 'fpulse-feedback-widget' ); ?>
				</p>
			</div>
		<?php endif; ?>

		<form action="options.php" method="post">
			<?php settings_fields( 'fpulse_fw' ); ?>
			<table class="form-table" role="presentation">
				<tr>
					<th scope="row"><label for="fpulse-widget-id"><?php esc_html_e( 'Widget ID or snippet', 'fpulse-feedback-widget' ); ?></label></th>
					<td>
						<input type="text" id="fpulse-widget-id" class="regular-text code" name="<?php echo esc_attr( $name ); ?>[widget_id]" value="<?php echo esc_attr( $settings['widget_id'] ); ?>" placeholder="fp_xxxxxxxxxxxx" />
						<p class="description"><?php esc_html_e( 'Paste the whole snippet from your F-Pulse dashboard, or just the ID that starts with fp_.', 'fpulse-feedback-widget' ); ?></p>
					</td>
				</tr>
				<tr>
					<th scope="row"><?php esc_html_e( 'Show the widget', 'fpulse-feedback-widget' ); ?></th>
					<td>
						<label><input type="checkbox" name="<?php echo esc_attr( $name ); ?>[enabled]" value="1" <?php checked( $settings['enabled'] ); ?> /> <?php esc_html_e( 'Show the feedback button on my site', 'fpulse-feedback-widget' ); ?></label><br />
						<label><input type="checkbox" name="<?php echo esc_attr( $name ); ?>[hide_for_admins]" value="1" <?php checked( $settings['hide_for_admins'] ); ?> /> <?php esc_html_e( 'Hide it from administrators', 'fpulse-feedback-widget' ); ?></label>
					</td>
				</tr>
				<tr>
					<th scope="row"><label for="fpulse-environment"><?php esc_html_e( 'Environment', 'fpulse-feedback-widget' ); ?></label></th>
					<td>
						<select id="fpulse-environment" name="<?php echo esc_attr( $name ); ?>[environment]">
							<option value="production" <?php selected( $settings['environment'], 'production' ); ?>><?php esc_html_e( 'Production (live site)', 'fpulse-feedback-widget' ); ?></option>
							<option value="development" <?php selected( $settings['environment'], 'development' ); ?>><?php esc_html_e( 'Development (test or staging site)', 'fpulse-feedback-widget' ); ?></option>
						</select>
						<p class="description"><?php esc_html_e( 'Feedback from a test site is kept separate in your dashboard.', 'fpulse-feedback-widget' ); ?></p>
					</td>
				</tr>
			</table>
			<?php submit_button(); ?>
		</form>

		<?php if ( '' !== $settings['widget_id'] ) : ?>
			<p>
				<?php if ( $settings['enabled'] ) : ?>
					<?php esc_html_e( 'The feedback button is live. Open your site in a private window to see it.', 'fpulse-feedback-widget' ); ?>
				<?php else : ?>
					<?php esc_html_e( 'The feedback button is turned off.', 'fpulse-feedback-widget' ); ?>
				<?php endif; ?>
				<a href="https://fpulse.app/dashboard/widget?utm_source=wordpress&amp;utm_medium=plugin&amp;utm_campaign=settings" target="_blank" rel="noopener noreferrer"><?php esc_html_e( 'Change colors and texts in your F-Pulse dashboard', 'fpulse-feedback-widget' ); ?></a>
			</p>
		<?php endif; ?>
	</div>
	<?php
}

/**
 * "Settings" link on the Plugins screen.
 *
 * @param string[] $links Existing action links.
 * @return string[]
 */
function fpulse_fw_action_links( $links ) {
	$url = admin_url( 'options-general.php?page=fpulse-feedback-widget' );
	array_unshift( $links, '<a href="' . esc_url( $url ) . '">' . esc_html__( 'Settings', 'fpulse-feedback-widget' ) . '</a>' );
	return $links;
}
add_filter( 'plugin_action_links_' . plugin_basename( __FILE__ ), 'fpulse_fw_action_links' );
