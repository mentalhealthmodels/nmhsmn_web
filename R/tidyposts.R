
write_to_update_md_links <- function(fl_nm_1L_chr,
                                     path_to_post_dir_1L_chr,
                                     path_to_content_1L_chr = "content",
                                     post_dir_nm_1L_chr = character(0)){
  # if(!identical(post_dir_nm_1L_chr, character(0))){
  #   if(is.na(post_dir_nm_1L_chr)){
  #     post_dir_nm_1L_chr <- fl_nm_1L_chr
  #   }
  # }
  file_path_1L_chr <- paste0(path_to_content_1L_chr,
                             path_to_post_dir_1L_chr,
                             "/",
                             post_dir_nm_1L_chr,
                             ifelse(!identical(post_dir_nm_1L_chr, character(0)),"/",""),
                             fl_nm_1L_chr,
                             ".md")
  text_chr <- readLines(file_path_1L_chr)
  text_chr <- gsub( "img src=\"figs/",
                    paste0("img src=\"",
                           path_to_post_dir_1L_chr,"/",
                           post_dir_nm_1L_chr,
                           ifelse(!identical(post_dir_nm_1L_chr, character(0)),"/",""),
                           paste0(fl_nm_1L_chr,"_files/figure-html/")),
                    text_chr)
  cat(text_chr, file=file_path_1L_chr, sep="\n")
}
# figs/
# /blog/resources/modeller-resources/tutorials/managing_open_data/managing_open_data_files/figure-html/

# path_to_content_dir_1L_chr = "content" 
# post_dir_nm_1L_chr <- "managing_open_data"
write_to_update_md_links(fl_nm_1L_chr = "managing_open_data",
                         path_to_post_dir_1L_chr = "/blog/resources/modeller-resources/tutorials/managing_open_data")
