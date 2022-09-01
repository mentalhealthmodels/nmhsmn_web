write_to_update_md_links <- function(fl_nm_1L_chr,
                                     path_to_post_dir_1L_chr,
                                     path_to_content_1L_chr = "content",
                                     post_dir_nm_1L_chr = character(0)){
  file_path_1L_chr <- paste0(path_to_content_1L_chr,
                             "/",
                             path_to_post_dir_1L_chr,
                             "/",
                             post_dir_nm_1L_chr,
                             ifelse(!identical(post_dir_nm_1L_chr, character(0)),"/",""),
                             fl_nm_1L_chr,
                             ".md")
  text_chr <- readLines(file_path_1L_chr)
  text_chr <- gsub( "img src=\"figs/",
                    paste0("img src=\"",
                           "/",
                           path_to_post_dir_1L_chr,
                           "/",
                           post_dir_nm_1L_chr,
                           ifelse(!identical(post_dir_nm_1L_chr, 
                                             character(0)),
                                  paste0("/",paste0(fl_nm_1L_chr,"_files/figure-html/")),
                                  "figs/")
                           ),
                    text_chr)
  cat(text_chr, file=file_path_1L_chr, sep="\n")
}
write_to_fix_ready4_in_md <- function(fl_nm_1L_chr,
                                      path_to_content_1L_chr,
                                      path_to_post_dir_1L_chr){
  path_part1_1L_chr <- paste0(path_to_content_1L_chr, "/", path_to_post_dir_1L_chr,"/",fl_nm_1L_chr)
  
  path_to_md_1L_chr <- paste0(path_part1_1L_chr,".md")
  text_chr <- readLines(path_to_md_1L_chr)
  yaml_yml <- rmarkdown::yaml_front_matter(paste0(path_part1_1L_chr,".Rmd"))
  yaml_chr <- yaml_yml  %>%
    ymlthis::yml() %>% print() %>% capture.output()
  yaml_chr[which(startsWith(yaml_chr,"authors:"))] <- yaml_chr[which(startsWith(yaml_chr,"authors:"))] %>% stringr::str_replace("authors: ","authors: \n- ") 
  cat(c(yaml_chr %>%
          head(-1),
        paste0("rmd_hash: ",
               digest::digest(paste0(path_part1_1L_chr,".Rmd"), file = TRUE, algo = "xxhash64")),
        yaml_chr %>% tail(1),
        "",
        text_chr), file=path_to_md_1L_chr, sep="\n")
}
## Call if problems rendering RMDs which make a library call to ready4
# write_to_fix_ready4_in_md(fl_nm_1L_chr = "Access_Open_Data",
#                           path_to_post_dir_1L_chr = "blog/resources/modeller-resources/tutorials/Managing-Open-Code-And-Data",
#                           path_to_content_1L_chr = "content")
## Call if rendering RMDs which create figures.
# write_to_update_md_links(fl_nm_1L_chr = "Access_Open_Data",
#                          path_to_post_dir_1L_chr = "blog/resources/modeller-resources/tutorials/Managing-Open-Code-And-Data")
