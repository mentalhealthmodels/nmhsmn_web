source("Prep/functions.R")
## Application
library(ready4)
read_and_tfm_pubs_df <- function(#path_to_existing_1L_chr = "content/blog/our-work/publications",
                                 #path_to_import_1L_chr = "Prep/Pubs_Import.xlsx",
  preprint_srvrs_chr = c("aRXiv", "bioRxiv","medRxiv","Research Square")){
  import_tbl_df <- readxl::read_xlsx("Prep/Pubs_Import.xlsx") %>%
    dplyr::mutate(dplyr::across(c("For Modellers", "For Planners", "About Policy", "About Methods"), as.logical)) %>%
    dplyr::mutate(Category = `For Modellers` %>% purrr::map_chr(~ifelse(is.na(.x),"", ifelse(.x,"MOD","")))) %>%
    dplyr::mutate(Category = `For Planners` %>% purrr::map2_chr(Category,~ifelse(is.na(.x),.y, ifelse(.x,
                                                                                                      paste0(.y,ifelse(.y=="","",", "),"PLA"),
                                                                                                      .y)))) %>%
    dplyr::mutate(Category = `About Policy` %>% purrr::map2_chr(Category,~ifelse(is.na(.x),.y, ifelse(.x,
                                                                                                      paste0(.y,ifelse(.y=="","",", "),"POL"),
                                                                                                      .y)))) %>%
    dplyr::mutate(Category = `About Methods` %>% purrr::map2_chr(Category,~ifelse(is.na(.x),.y, ifelse(.x,
                                                                                                       paste0(.y,ifelse(.y=="","",", "),"MET"),
                                                                                                       .y)))) 
  existing_nms_chr <- list.files(path = "content/blog/our-work/publications") %>% stringr::str_remove_all(".md")
  pubs_df <- purrr::map_dfr(1:nrow(import_tbl_df),
                            ~ make_pubs_df(categories_chr = import_tbl_df$Category[.x] %>% purrr::map_chr(~transform_categories(.x)),
                                           dois_chr = import_tbl_df$DOI[.x],
                                           existing_nms_chr = existing_nms_chr,
                                           given_nm_1L_chr = import_tbl_df$`First Author`[.x] %>% purrr::map_chr(~stringr::word(.x,1)),
                                           keywords_chr = import_tbl_df$Tags[.x],
                                           methods_chr = import_tbl_df$Method[.x],
                                           message_chr = import_tbl_df$Message[.x],
                                           middle_nms_chr = import_tbl_df$`First Author`[.x] %>% purrr::map_chr(~ifelse(is.na(stringr::word(.x,3)),
                                                                                                                        NA_character_,
                                                                                                                        stringr::word(.x,2))),
                                           family_nm_1L_chr = import_tbl_df$`First Author`[.x] %>% purrr::map_chr(~ifelse(is.na(stringr::word(.x,3)),
                                                                                                                          stringr::word(.x,2),
                                                                                                                          stringr::word(.x,3))),
                                           auth_nm_tag_1L_chr = import_tbl_df$`First Author`[.x],
                                           preprint_srvrs_chr = preprint_srvrs_chr))

  return(pubs_df)
}
pubs_df <- read_and_tfm_pubs_df(#path_to_existing_1L_chr = 'content/blog/our-work/publications',
                                #path_to_import_1L_chr = "Prep/Pubs_Import.xlsx",
                                preprint_srvrs_chr = c("aRXiv", "bioRxiv","medRxiv","Research Square"))
#mssng_vals_ls <- make_mssng_vals_ls(pubs_df)
pubs_entries_ls <- make_pubs_entries_ls(pubs_df,
                                        tmpl_pub_md_chr = readLines("Prep/pub_template/publication.md"))
write_items_as_md(pubs_entries_ls,
                  pub_entries_dir_1L_chr = "content/blog/our-work/publications",#"content/publication",
                  overwrite_1L_lgl = T)
# 
# pubs_df <- make_pubs_df(#path_to_bib_1L_chr = "PREP/sydney.bib",#"PREP/My_PR_PUBS.bib"
#   categories_chr = c("MOD, PLA, POL") %>% transform_categories(),
#   dois_chr = "https://doi.org/10.1192/bjo.2021.989",
#   existing_nms_chr = list.files("content/blog/our-work/publications") %>% stringr::str_remove_all(".md"),
#   given_nm_1L_chr = "Adam",
#   keywords_chr = c("Prevention, Regional Planning, Systems Dynamics Models, Suicide Prevention"),
#   methods_chr = c("A systems dynamics model for 10 Primary Health Networks (PHNs) in New South Wales that serve reguibs that vary in terms of population size, geographic area, population density, levels of disadvantage and suicide rates."),
#   message_chr = "There is potential for substantial variation in projected reductions in suicide mortality if implementing a standardised state-based suicide prevention strategy versus a regionally driven approach.",
#   #middle_nms_chr = "Phillip",
#   family_nm_1L_chr = "Skinner",
#   auth_nm_tag_1L_chr = "Adam Skinner",
#   preprint_srvrs_chr = c("aRXiv", "bioRxiv","medRxiv","Research Square")) 
# unlink(paste0("content/publication/",
#               c("conference-paper","journal-article","preprint")), 
#        recursive = T)

