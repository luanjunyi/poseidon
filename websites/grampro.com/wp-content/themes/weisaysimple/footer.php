<div class="clear"></div>
<div id="footer">Copyright <?php echo comicpress_copyright(); ?> <?php bloginfo('name'); ?>. Powered by <a href="http://www.wordpress.org/" rel="external">WordPress</a>.
 Theme by <a href="http://www.weisay.com/" rel="external">Weisay</a>.
 <?php if (get_option('swt_beian') == 'Display') { ?><a href="http://www.miitbeian.gov.cn/" rel="external"><?php echo stripslashes(get_option('swt_beianhao')); ?></a><?php { echo '.'; } ?><?php } else { } ?> <?php if (get_option('swt_tj') == 'Display') { ?><?php echo stripslashes(get_option('swt_tjcode')); ?><?php { echo '.'; } ?>	<?php } else { } ?>
 </div>
<?php wp_footer(); ?>
</div>
</body>
</html>