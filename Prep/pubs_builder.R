source("Prep/functions.R")
## Application
library(ready4)
pubs_df <- make_pubs_df(#path_to_bib_1L_chr = "PREP/sydney.bib",#"PREP/My_PR_PUBS.bib"
  categories_chr = c("MOD, PLA, POL") %>% transform_categories(),
  dois_chr = "https://doi.org/10.1192/bjo.2021.989",
                        existing_nms_chr = list.files("content/blog/our-work/publications") %>% stringr::str_remove_all(".md"),
                        given_nm_1L_chr = "Adam",
                        keywords_chr = c("Prevention, Regional Planning, Systems Dynamics Models, Suicide Prevention"),
  methods_chr = c("A systems dynamics model for 10 Primary Health Networks (PHNs) in New South Wales that serve reguibs that vary in terms of population size, geographic area, population density, levels of disadvantage and suicide rates."),
  message_chr = "There is potential for substantial variation in projected reductions in suicide mortality if implementing a standardised state-based suicide prevention strategy versus a regionally driven approach.",
                        #middle_nms_chr = "Phillip",
                        family_nm_1L_chr = "Skinner",
                        auth_nm_tag_1L_chr = "Adam Skinner",
                        preprint_srvrs_chr = c("aRXiv", "bioRxiv","medRxiv","Research Square")) 
#mssng_vals_ls <- make_mssng_vals_ls(pubs_df)
pubs_entries_ls <- make_pubs_entries_ls(pubs_df,
                                        tmpl_pub_md_chr = readLines("Prep/pub_template/publication.md"))
write_items_as_md(pubs_entries_ls,
                  pub_entries_dir_1L_chr = "Prep/Test",#"content/publication",
                  overwrite_1L_lgl = F)
unlink(paste0("content/publication/",
              c("conference-paper","journal-article","preprint")), 
       recursive = T)

# Manual edits to Eoin, Mario and pub type for preprint.
