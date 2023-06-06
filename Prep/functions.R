# Functions
add_auth_tags_to_pubs_df <- function(pubs_df,
                                     cref_res_ls,
                                     auth_nm_matches_chr,
                                     auth_nm_tag_1L_chr = "admin"){
  pubs_df <- pubs_df %>%
    dplyr::mutate(auth_first_family_ls = DOI %>% 
                    purrr::map(~ if(is.na(.x) | is.null(cref_res_ls %>%
                                                        purrr::pluck(.x))){
                      names_chr <- NA_character_
                    }else{
                      cref_res_ls %>%
                        purrr::pluck(.x) %>%
                        purrr::pluck("author") %>%
                        dplyr::mutate(full_nm_chr = paste0(given," ",family)) %>%
                        dplyr::pull(full_nm_chr)
                    })) %>%
    dplyr::mutate(auth_first_family_ls = dplyr::case_when(auth_first_family_ls %>%
                                                            purrr::map_lgl(~is.na(.x[1])) ~ AUTHOR %>% 
                                                            purrr::map(~{
                                                              .x %>% purrr::map_chr(~{
                                                                ifelse(stringr::str_detect(.x,","),
                                                                       {
                                                                         name_chr <- strsplit(.x,",")[[1]] %>% 
                                                                           trimws()
                                                                         paste0(name_chr[-1]," ",name_chr[1])
                                                                       },
                                                                       .x) %>% stringr::str_replace_all("â€ "," ")
                                                              })}),
                                                          T ~ auth_first_family_ls)) %>%
    dplyr::mutate(auth_tags_chr = auth_first_family_ls %>% 
                    purrr::map_chr(~{
                      paste0(" - ",
                             .x %>% purrr::map_chr(~{
                               ifelse(.x %in% auth_nm_matches_chr,
                                      auth_nm_tag_1L_chr,
                                      .x)
                             }), 
                             collapse = "\n")
                    })) 
  return(pubs_df)
}
add_jrnl_tags_to_pubs_df <-  function(pubs_df,
                                      cref_res_ls = cref_res_ls){
  pubs_df <- pubs_df %>%
    dplyr::mutate(jrnl_long_nm_tags_chr = purrr::pmap_chr(pubs_df %>%
                                                            dplyr::select(DOI, JOURNAL, TYPE),
                                                          ~ ifelse(is.na(..1),
                                                                   ..2, 
                                                                   {jrnl_long_1L_chr <- cref_res_ls %>%
                                                                     purrr::pluck(..1) %>%
                                                                     purrr::pluck("container-title")
                                                                   if(is.null(jrnl_long_1L_chr))
                                                                     jrnl_long_1L_chr <- ifelse(..3 %in% c("Program","Library"),
                                                                                                "Zenodo",
                                                                                                ifelse(..3 %in% c("Results","Synthetic"),
                                                                                                       "Harvard Dataverse",
                                                                                                       ..2))
                                                                   jrnl_long_1L_chr
                                                                   }))) %>%
    dplyr::mutate(jrnl_short_nm_tags_chr = purrr::map2_chr(.$DOI, 
                                                           .$jrnl_long_nm_tags_chr, 
                                                           ~ ifelse(is.na(.x),
                                                                    .y, 
                                                                    {jrnl_short_1L_chr <- cref_res_ls %>%
                                                                      purrr::pluck(.x) %>%
                                                                      purrr::pluck("container-title-short")
                                                                    if(is.null(jrnl_short_1L_chr))
                                                                      jrnl_short_1L_chr <- .y
                                                                    jrnl_short_1L_chr
                                                                    })))
  return(pubs_df)
}
add_keywd_tags_to_pubs_df <- function(pubs_df,
                                      tag_var_1L_chr = "keywd_tags_chr",
                                      var_nm_1L_chr = "KEYWORDS"){
  pubs_df <- pubs_df %>%
    dplyr::mutate(!!rlang::sym(tag_var_1L_chr) := !!rlang::sym(var_nm_1L_chr) %>% 
                    purrr::map_chr(~{
                      ifelse(is.na(.x),
                             "# No Keywords",
                             strsplit(.x, split = ", ") %>% 
                               purrr::map_chr(~ paste0(" - ",
                                                       .x %>% 
                                                         stringr::str_replace_all("\\*","") %>%
                                                         toupper(), 
                                                       collapse = "\n")
                               ))
                    })
    ) 
  return(pubs_df)
}
add_summary_tags_to_pubs_df <- function(pubs_df){
  pubs_df <- pubs_df %>%
    dplyr::mutate(abstract_tags_chr = ABSTRACT %>% transform_abstract_ls()) %>%
    dplyr::mutate(summary_tags_chr = abstract_tags_chr %>% purrr::map_chr(~corpus::text_split(.x) %>%
                                                                            dplyr::mutate(text = as.character(text)) %>%
                                                                            dplyr::slice(1:2) %>%
                                                                            dplyr::pull("text") %>%
                                                                            as.vector() %>%
                                                                            paste0(collapse=" ") %>%
                                                                            trimws()  %>%
                                                                            paste0("..")))
  return(pubs_df)
}
add_url_tag_vars_to_pubs_df <- function(pubs_df){ # Purely placeholder for the moment. Needs updating
  updated_pubs_df <- pubs_df %>%
    dplyr::mutate(name_url_tags_chr = ifelse(T, # MODIFY
                                             paste0("# links:\n# - name: \"\"\n#   url: \"\""),
                                             paste0("links:\n - name: \"NAME_GOES_HERE\"\n   url: \"URL_GOES_HERE\"") # MODIFY
    ),
    pdf_url_tags_chr = ifelse(T, # MODIFY
                              paste0("# url_pdf: ''"),
                              paste0("url_pdf: URL_GOES_HERE") # MODIFY
    ),
    code_url_tags_chr = ifelse(T, # MODIFY
                               paste0("# url_dataset: ''"),
                               paste0("url_dataset: 'URL_GOES_HERE'") # MODIFY
    ),
    dataset_url_tags_chr = ifelse(T, # MODIFY
                                  paste0("# url_dataset: ''"),
                                  paste0("url_dataset: 'URL_GOES_HERE'") # MODIFY
    ),
    poster_url_tags_chr = ifelse(T, # MODIFY
                                 paste0("# url_poster: ''"),
                                 paste0("url_poster: 'URL_GOES_HERE'") # MODIFY
    ),
    project_url_tags_chr = ifelse(T, # MODIFY
                                  paste0("# url_project: ''"),
                                  paste0("url_project: 'URL_GOES_HERE'") # MODIFY
    ),
    slides_url_tags_chr = ifelse(T, # MODIFY
                                 paste0("# url_slides: ''"),
                                 paste0("url_slides: 'URL_GOES_HERE'") # MODIFY
    ),
    source_url_tags_chr = ifelse(T, # MODIFY
                                 paste0("# url_source: ''"),
                                 paste0("url_source: 'URL_GOES_HERE'") # MODIFY
    ),
    video_url_tags_chr = ifelse(T, # MODIFY
                                paste0("# url_video: '' "),
                                paste0("url_video: 'URL_GOES_HERE'") # MODIFY
    )
    )
  return(updated_pubs_df)
}
make_terms_chr <- function(term_1L_chr){
  terms_chr <- c(c(term_1L_chr,c(term_1L_chr) %>% 
                     toupper(),c(term_1L_chr,
                                 c(term_1L_chr) %>% toupper()) %>% paste0(":")))
  return(terms_chr)
}
make_nm_combns <- function(given_nm_1L_chr,
                           middle_nms_chr = NA_character_,
                           family_nm_1L_chr){
  all_names_chr <- c(given_nm_1L_chr, middle_nms_chr, family_nm_1L_chr) %>% na.omit()
  names_df <- all_names_chr[-length(all_names_chr)] %>%
    purrr::map_dfc(~c(.x, substring(.x, 1, 1), paste0(substring(.x, 1, 1),"."))) %>%
    stats::setNames(all_names_chr[-length(all_names_chr)])
  if(length(all_names_chr)>2)
    names_df <- 1:length(middle_nms_chr) %>% purrr::reduce(.init = names_df,
                                                           ~ dplyr::bind_rows(.x,
                                                                              .x[2:nrow(.x),] %>%
                                                                                dplyr::mutate(!!rlang::sym(all_names_chr[.y]) := all_names_chr[.y])) %>%
                                                             dplyr::distinct())
  1:ncol(names_df)
  names_df <- names_df %>%
    dplyr::mutate(!!rlang::sym(family_nm_1L_chr) := family_nm_1L_chr) 
  all_nm_combns_chr <- assertr::col_concat(names_df, sep = " ")
  return(all_nm_combns_chr)
}
get_auth_surnm_mtchs <- function(authorship_ls,
                                 surname_1L_chr){
  surname_matches_chr <- authorship_ls %>% 
    purrr::map_chr(~.x[stringr::str_detect(.x,surname_1L_chr)]) %>% 
    unique()
  return(surname_matches_chr)
}
get_refs_of_missing_var <- function(pubs_df,
                                    var_nm_1L_chr){
  mssng_pub_refs_chr <- pubs_df %>% 
    dplyr::filter(is.na(!!rlang::sym(var_nm_1L_chr))) %>% 
    dplyr::pull(unique_pub_ref_nms_chr)
  return(mssng_pub_refs_chr)
}
make_cref_res_ls <- function(doi_chr){ # Add argument for cref polite option
  cref_res_ls <- rcrossref::cr_cn(doi_chr %>% na.omit() %>% as.vector(), 
                                  format = "citeproc-json") 
  if(length(doi_chr==1)){
    cref_res_ls <- list(cref_res_ls)
  }
  cref_res_ls <- cref_res_ls %>% 
    stats::setNames(doi_chr %>% na.omit() %>% as.vector())
  return(cref_res_ls)
}
make_mssng_vals_ls <- function(pubs_df,
                               include_int = 1:16){
  mssng_vals_ls <- purrr::map(names(pubs_df)[include_int],#1:2,6:8,13:15,18,23:31#23:33
                              ~  get_refs_of_missing_var(pubs_df,
                                                         var_nm_1L_chr = .x)) %>%
    stats::setNames(names(pubs_df)[include_int]) %>% #23:33
    purrr::discard(identical,y= character(0))
  return(mssng_vals_ls)
}
add_publn_date_tags_to_pubs_df <- function(pubs_df,
                                           cref_res_ls){
  pubs_df <- pubs_df %>%
    dplyr::mutate(publn_date_tags_chr = DOI %>% 
                    purrr::map_chr(~ ifelse(is.na(.x) | is.null(cref_res_ls %>%
                                                                  purrr::pluck(.x)),
                                            NA_character_, 
                                            cref_res_ls %>%
                                              purrr::pluck(.x) %>%
                                              purrr::pluck("created") %>%
                                              purrr::pluck(2))))
  return(pubs_df)
}
add_doi_tags_to_pubs_df <- function(pubs_df){
  pubs_df <- pubs_df %>%
    dplyr::mutate(doi_tags_chr = DOI %>% purrr::map_chr(~ ifelse(is.na(.x),
                                                                 "#doi: ",
                                                                 paste0("doi: ",.x))))
  return(pubs_df)
}
add_pub_types_to_pubs_df <- function(pubs_df,
                                     preprint_srvrs_chr = c("aRXiv","bioRxiv","medRxiv")){
  pubs_df <- pubs_df %>%
    dplyr::mutate(pub_type_tags_chr = purrr::map2_chr(.$TYPE,
                                                      .$jrnl_long_nm_tags_chr, 
                                                      ~ ifelse(.x %in% c("Program","Library"),
                                                               "9",
                                                               ifelse(.x %in% c("Results","Synthetic"),
                                                                      "10",
                                                                      ifelse(is.na(.x),
                                                                             "3",
                                                                             ifelse(.x == "Journal Article",
                                                                                    ifelse(.y %in% preprint_srvrs_chr,
                                                                                           "3",
                                                                                           "2"),
                                                                                    "4"))))
    ))
  return(pubs_df)
}
make_pubs_df <- function(#path_to_bib_1L_chr,
  categories_chr,
  dois_chr,
  given_nm_1L_chr,
  keywords_chr,
  message_chr,
  methods_chr,
  middle_nms_chr = NA_character_,
  family_nm_1L_chr,
  auth_nm_tag_1L_chr = "admin",
  existing_nms_chr = NA_character_,
  preprint_srvrs_chr = c("aRXiv","bioRxiv","medRxiv")){
  auth_nm_matches_chr <- make_nm_combns(given_nm_1L_chr = given_nm_1L_chr,
                                        middle_nms_chr = middle_nms_chr,
                                        family_nm_1L_chr = family_nm_1L_chr)
  #spine_of_pubs_df <- bib_pubs_df <- bib2df::bib2df(path_to_bib_1L_chr) 
  spine_of_pubs_df <- tibble::tibble(ABSTRACT = "",
                                     AUTHOR = "",
                                     BIBTEX = "",
                                     CATEGORIES = categories_chr,
                                     DOI = dois_chr,
                                     JOURNAL = "",
                                     KEYWORDS = keywords_chr,
                                     MESSAGE = message_chr,
                                     METHOD = methods_chr)
  spine_of_pubs_df <- spine_of_pubs_df %>%
    dplyr::mutate(DOI = purrr::map_chr(DOI,
                                       ~ ifelse(is.na(.x) | startsWith(.x,"https://doi.org/"),
                                                .x,
                                                paste0("https://doi.org/",.x))))
  cref_res_ls <- make_cref_res_ls(spine_of_pubs_df$DOI)
  pubs_df <- spine_of_pubs_df %>%
    # dplyr::mutate(TITLE = DOI %>% purrr::map_chr(~cref_res_ls %>%
    #                 purrr::pluck(.x) %>%
    #                 purrr::pluck("title")))
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "abstract" ,var_nm_1L_chr = "ABSTRACT") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "author",var_nm_1L_chr = "AUTHOR", 
                         fn = function(x){
                           x %>% 
                             dplyr::mutate(full_nm_chr = paste0(family, ", ",given)) %>%
                             dplyr::pull(full_nm_chr) %>% paste0(collapse = " and ")
                           }) %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "container-title", var_nm_1L_chr = "JOURNAL") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "journal-issue", var_nm_1L_chr = "NUMBER", fn = function(x){x$issue}) %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "article-number", var_nm_1L_chr = "PAGES") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "publisher", var_nm_1L_chr = "PUBLISHER") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "title", var_nm_1L_chr = "TITLE") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "type", var_nm_1L_chr = "TYPE") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "volume", var_nm_1L_chr = "VOLUME") %>%
    add_var_from_cref_ls(cref_res_ls = cref_res_ls, element_nm_1L_chr = "published" ,var_nm_1L_chr = "YEAR", fn = function(x){as.character(x$`date-parts`[1,1])}) 
  pubs_df <- pubs_df %>%
    add_auth_tags_to_pubs_df(cref_res_ls = cref_res_ls,
                             auth_nm_matches_chr = auth_nm_matches_chr,
                             auth_nm_tag_1L_chr = auth_nm_tag_1L_chr) %>%
    add_doi_tags_to_pubs_df() %>%
    #add_summary_tags_to_pubs_df() %>%
    #add_url_tag_vars_to_pubs_df() %>%
    add_keywd_tags_to_pubs_df(tag_var_1L_chr = "ctg_tags_chr",
                              var_nm_1L_chr = "CATEGORIES") %>%
    add_keywd_tags_to_pubs_df(tag_var_1L_chr = "keywd_tags_chr",
                              var_nm_1L_chr = "KEYWORDS") %>%
    add_publn_date_tags_to_pubs_df(cref_res_ls = cref_res_ls) %>%
    add_jrnl_tags_to_pubs_df(cref_res_ls = cref_res_ls) %>%
    # dplyr::mutate(AUTHOR = auth_first_family_ls %>% purrr::map_chr(~ready4::make_list_phrase(.x))) %>%
    # dplyr::mutate(JOURNAL = jrnl_long_nm_tags_chr) %>%
    add_pub_types_to_pubs_df(preprint_srvrs_chr = preprint_srvrs_chr)
  pubs_df <- pubs_df %>%
  #%>%
    # dplyr::select(TITLE,
    #               ABSTRACT, abstract_tags_chr, summary_tags_chr, AUTHOR, auth_tags_chr, DOI, doi_tags_chr, JOURNAL, VOLUME, NUMBER, PAGES, jrnl_long_nm_tags_chr, jrnl_short_nm_tags_chr, KEYWORDS, keywd_tags_chr, YEAR, publn_date_tags_chr, CATEGORY, TYPE, pub_type_tags_chr,
    #               #ISSN, 
    #               #URL,
    #               name_url_tags_chr, pdf_url_tags_chr, code_url_tags_chr, dataset_url_tags_chr, poster_url_tags_chr, project_url_tags_chr, slides_url_tags_chr, source_url_tags_chr, video_url_tags_chr) %>%
    dplyr::mutate(unique_pub_ref_nms_chr = make_unique_pub_ref_nms(.,
                                                                   existing_nms_chr = existing_nms_chr))  %>% 
    add_bibtex()
  return(pubs_df)
}
add_bibtex <- function(pubs_df,
                       var_nm_1L_chr = "BIBTEX"){
 pubs_df <- pubs_df %>% 
   dplyr::mutate(!!rlang::sym(var_nm_1L_chr) := purrr::pmap(.,~paste0("@article{",..26,", title={",..13,"}, author={",..2,"}, journal={",..6,"}, volume={",..15,
                                                                    "}, pages={",..11,"}, year={",
                                                                    ..16,"}, publisher={",..12,"}}")))
   
 return(pubs_df)
 }
add_var_from_cref_ls <- function(pubs_df, cref_res_ls, element_nm_1L_chr, var_nm_1L_chr, fn = identity, match_1L_chr = "DOI"){
  pubs_df <- pubs_df %>%
    dplyr::mutate(!!rlang::sym(var_nm_1L_chr) := !!rlang::sym(match_1L_chr) %>% purrr::map_chr(~{
      value_ls <- cref_res_ls %>%
        purrr::pluck(.x) 
      if(element_nm_1L_chr %in% names(value_ls)){
        value_ls %>%
          purrr::pluck(element_nm_1L_chr) %>%
          fn
      }else{
        ""
      }
      }))
  return(pubs_df)
}
make_pubs_df_spine <- function(bib_pubs_df,
                               auth_nm_matches_chr){
  spine_of_pubs_df <- bib_pubs_df %>%
    add_auth_tags_to_pubs_df(auth_nm_matches_chr = auth_nm_matches_chr)
  return(spine_of_pubs_df)
}
make_pubs_entries_ls <- function(pubs_df,
                                 tmpl_pub_md_chr){
  entries_ls <- purrr::pmap(pubs_df,
                            ~{
                              ABSTRACT_PLACEHODER <- ..1
                              AUTHOR_PLACEHODER <- ..17
                              AUTHOR_LIST_PLACEHOLDER <- ..2
                              BIBTEX_PLACEHOLDER <- ..3 
                              CATEGORIES_PLACEHOLDER <- ..20
                              DATE_PLACEHOLDER <- ..22
                              DOI_PLACEHOLDER <- ..5
                              JOURNAL_LONG_PLACEHOLDER <- ..6
                              KEYWORDS_PLACEHOLDER <- ..21
                              METHOD_PLACEHOLDER <- ..9
                              MESSAGE_PLACEHOLDER <- ..8
                              PR_PLACEHOLDER <- ifelse(..25 =="4","Yes","No")
                              TITLE_PLACEHOLDER <- ..13
                              YEAR_PLACEHOLDER <- ..16
                              pub_entry_chr <- purrr::map_chr(tmpl_pub_md_chr, ~ {
                                .x %>%
                                  stringr::str_replace("AUTHOR_LIST_PLACEHOLDER",AUTHOR_LIST_PLACEHOLDER) %>%
                                  stringr::str_replace("BIBTEX_PLACEHOLDER",BIBTEX_PLACEHOLDER) %>%
                                  stringr::str_replace("CATEGORIES_PLACEHOLDER",CATEGORIES_PLACEHOLDER) %>%
                                  stringr::str_replace_all("DATE_PLACEHOLDER",DATE_PLACEHOLDER) %>%
                                  stringr::str_replace("DOI_PLACEHOLDER",DOI_PLACEHOLDER) %>%
                                  stringr::str_replace("JOURNAL_LONG_PLACEHOLDER",JOURNAL_LONG_PLACEHOLDER) %>%
                                  stringr::str_replace("KEYWORDS_PLACEHOLDER",KEYWORDS_PLACEHOLDER) %>%
                                  stringr::str_replace("METHOD_PLACEHOLDER",METHOD_PLACEHOLDER) %>%
                                  stringr::str_replace("MESSAGE_PLACEHOLDER",MESSAGE_PLACEHOLDER) %>%
                                  stringr::str_replace("PR_PLACEHOLDER",PR_PLACEHOLDER) %>%
                                  stringr::str_replace("TITLE_PLACEHOLDER",TITLE_PLACEHOLDER) %>%
                                  stringr::str_replace("YEAR_PLACEHOLDER",YEAR_PLACEHOLDER)
                              }) 
                              index_1L_int <- stringr::str_locate(pub_entry_chr, "# No Keywords") %>% tibble::as_tibble() %>% dplyr::mutate(index_int = 1:length(pub_entry_chr)) %>% na.omit() %>% dplyr::pull(index_int)
                              if(!identical(integer(0),index_1L_int))
                                pub_entry_chr[index_1L_int-1] <- "# tags:"
                              pub_entry_chr
                              #
                            }) %>%
    stats::setNames(pubs_df$unique_pub_ref_nms_chr)
  return(entries_ls)
}
make_unique_pub_ref_nms <- function(pubs_df,
                                    existing_nms_chr = NA_character_){
  unique_pub_dir_nms_chr <- pubs_df %>% 
    purrr::pmap_chr(~paste0(stringr::word(..2[1]) %>% 
                              stringr::str_replace(",",""),
                            stringr::word(..2[1],start = 2) %>% stringr::str_sub(end=1),
                            #"_",
                            stringr::word(..13),
                            #"_",
                            ..16#,
                            #"_",
                           # stringr::word(..1)
                            )) %>% 
    stringr::str_replace_all("\\:","_") %>%
    make.unique() %>% 
    stringr::str_replace_all("\\.","_")
  if(!is.na(existing_nms_chr[1])){
    unique_pub_dir_nms_chr <- unique_pub_dir_nms_chr %>%
      purrr::map_chr(~{
        name_1L_chr <- .x
        repeating_chr <- existing_nms_chr %>%
          purrr::map_lgl(~startsWith(.x,name_1L_chr))
        if(length(repeating_chr)>0)
          paste0(name_1L_chr,LETTERS[length(repeating_chr)])
      })
  }
  return(unique_pub_dir_nms_chr)
}
replace_mssng_vals_in_pubs_df <- function(pubs_df,
                                          mssng_vals_ls,
                                          replacements_ls,
                                          preprint_srvrs_chr = c("aRXiv","bioRxiv","medRxiv"),
                                          given_nm_1L_chr = NA_character_,
                                          middle_nms_chr = NA_character_,
                                          family_nm_1L_chr = NA_character_,
                                          auth_nm_tag_1L_chr = "admin"){
  mssng_vals_ls <- mssng_vals_ls[names(replacements_ls)]
  updated_pubs_df <- 1:length(mssng_vals_ls) %>% purrr::reduce(.init = pubs_df,
                                                               ~ {
                                                                 replacement_lup <- tibble::tibble(ref_chr = mssng_vals_ls[[.y]],
                                                                                                   val_chr = replacements_ls[[.y]])
                                                                 .x %>% 
                                                                   dplyr::mutate(!!rlang::sym(names(replacements_ls)[.y]) := dplyr::case_when(unique_pub_ref_nms_chr %in% mssng_vals_ls[[.y]] ~ unique_pub_ref_nms_chr %>%
                                                                                                                                                purrr::map_chr(~{
                                                                                                                                                  ifelse(.x %in% replacement_lup$ref_chr,
                                                                                                                                                         ready4::get_from_lup_obj(replacement_lup,
                                                                                                                                                                                  target_var_nm_1L_chr = "val_chr",
                                                                                                                                                                                  match_var_nm_1L_chr = "ref_chr",
                                                                                                                                                                                  match_value_xx = .x,
                                                                                                                                                                                  evaluate_1L_lgl = F),
                                                                                                                                                         NA_character_)}),
                                                                                                                                              T ~ !!rlang::sym(names(replacements_ls)[.y])))
                                                               })
  if("DOI" %in% names(replacements_ls)){
    cref_res_ls <- make_cref_res_ls(spine_of_pubs_df$DOI)
    updated_pubs_df <- updated_pubs_df %>%
      add_doi_tags_to_pubs_df() %>%
      add_publn_date_tags_to_pubs_df(cref_res_ls = cref_res_ls)
  }
  if("DOI" %in% names(replacements_ls) | "AUTHOR" %in% names(replacements_ls)){
    auth_nm_matches_chr <- make_nm_combns(given_nm_1L_chr = given_nm_1L_chr,
                                          middle_nms_chr = middle_nms_chr,
                                          family_nm_1L_chr = family_nm_1L_chr)
    updated_pubs_df <- updated_pubs_df %>%
      add_auth_tags_to_pubs_df(cref_res_ls = cref_res_ls,
                               auth_nm_matches_chr = auth_nm_matches_chr,
                               auth_nm_tag_1L_chr = auth_nm_tag_1L_chr)
  }
  if(c("DOI","JOURNAL") %>% purrr::map_lgl(~.x %in% names(replacements_ls)) %>% any()){
    updated_pubs_df <- updated_pubs_df %>%
      add_jrnl_tags_to_pubs_df(cref_res_ls = cref_res_ls)
    
  }
  if(c("DOI","JOURNAL","TYPE") %>% purrr::map_lgl(~.x %in% names(replacements_ls)) %>% any()){
    updated_pubs_df <- updated_pubs_df %>%
      add_pub_types_to_pubs_df(preprint_srvrs_chr = preprint_srvrs_chr) 
  }
  if("ABSTRACT" %in% names(replacements_ls)){
    updated_pubs_df <- updated_pubs_df %>%
      add_summary_tags_to_pubs_df()
  }
  if("KEYWORDS" %in% names(replacements_ls)){
    updated_pubs_df <- updated_pubs_df %>%
      add_keywd_tags_to_pubs_df()
  }
  #add_url_tag_vars_to_pubs_df() %>% # To be added later.
  return(updated_pubs_df)
}
transform_abstract_ls <- function(abstract_ls){
  abstracts_chr <- abstract_ls %>% purrr::map(~corpus::text_split(.x) %>%
                                                dplyr::mutate(text = as.character(text)) %>%
                                                dplyr::pull("text")) %>%
    purrr::map(~{
      abstract_chr <- .x
      abstract_chr[1] <- ifelse(stringr::word(abstract_chr[1]) %in% (purrr::map(c("Abstract", "Summary"),
                                                                                ~ make_terms_chr(.x)) %>%
                                                                       purrr::flatten_chr()),
                                stringr::str_remove(abstract_chr[1],
                                                    stringr::word(abstract_chr[1])) %>%
                                  trimws(which = "left"),
                                abstract_chr[1])
      purrr::map2_chr(abstract_chr,
                      abstract_chr %>%
                        purrr::map_lgl(~
                                         (stringr::str_detect(.x,
                                                              "^\\b[A-Z]\\w+:?\\s+\\b[A-Z]")[[1]] |
                                            stringr::word(.x) == .x)

                        ),
                      ~ ifelse(.y,
                               stringr::str_replace(.x,
                                                    stringr::word(.x),
                                                    paste0("**",
                                                           stringr::word(.x),
                                                           "**")),
                               .x)
      )
    }) %>%
    purrr::map_chr(~{
      collapsed_1L_chr <- paste0(.x, collapse = "")
      ifelse(collapsed_1L_chr == "NA",
             NA_character_,
             collapsed_1L_chr)
    })
  return(abstracts_chr)
}
transform_categories <- function(categories_chr){
  categories_chr <- categories_chr %>% 
    strsplit(", ") %>% purrr::pluck(1) %>%
    purrr::map_chr(~switch(.x,
                           "MOD" = "Resources for Modellers",
                           "PLA" = "Resources for Planners",
                           "MET" = "Publications (Modelling Methods)", 
                           "POL" = "Publications (Mental Health Policy)")) %>% paste0(collapse = ", ")
  return(categories_chr)
}
write_items_as_md <- function(entries_ls,
                                 pub_entries_dir_1L_chr,
                                 overwrite_1L_lgl = F){
  1:length(entries_ls) %>% purrr::walk(~{
    pub_nm_dir_1L_chr <- names(entries_ls)[.x]
    pub_entry_chr <- entries_ls[[.x]]
    #new_entry_dir_1L_chr <- paste0(pub_entries_dir_1L_chr,"/",pub_nm_dir_1L_chr)
    new_entry_file_1L_chr <- paste0(pub_entries_dir_1L_chr,
                                    "/",
                                    pub_nm_dir_1L_chr,
                                    ".md"
                                    #new_entry_dir_1L_chr,"/index.md"
                                    )
    # if(!dir.exists(new_entry_dir_1L_chr))
    #   dir.create(new_entry_dir_1L_chr)
    if(!file.exists(new_entry_file_1L_chr) | overwrite_1L_lgl)
      pub_entry_chr %>% writeLines(new_entry_file_1L_chr) 
  }
  )
}
# add_unique_talk_ref_to_talks_df <- function(talks_df){
#   talks_df <- talks_df %>%
#     dplyr::mutate(unique_talk_ref_nms_chr = talks_df %>% dplyr::select(Title, Event, Location, Year) %>% 
#                     purrr::pmap_chr(~paste0(stringr::word(..1, end=2) %>% stringr::str_replace_all(" ","_"),
#                                             "_",
#                                             stringr::word(..2),
#                                             "_",
#                                             stringr::word(..3),
#                                             "_",
#                                             ..4) %>% stringr::str_replace_all("\\\"","") %>%
#                                       stringr::str_replace_all("\\,","") %>%
#                                       stringr::str_replace_all("\\:","") ) %>% make.unique())
#   return(talks_df)
# }
# make_talks_entries_ls <- function(talks_df,
#                                   tmpl_talk_md_chr,
#                                   auth_nm_matches_chr,
#                                   auth_nm_tag_1L_chr = "admin"){
#   talks_df <- talks_df %>%
#     dplyr::mutate(dplyr::across(.fns = as.character)) %>%
#     add_keywd_tags_to_pubs_df() %>%
#     tibble::as_tibble() %>%
#     dplyr::mutate(author_ls = Author %>% 
#                     purrr::map(~strsplit(.x,(",")) %>% 
#                                  purrr::pluck(1) %>% 
#                                  purrr::map(~.x %>% strsplit(" and ") %>%
#                                               purrr::pluck(1)) %>%
#                                  purrr::flatten_chr() %>%
#                                  purrr::map_chr(~stringr::str_replace_all(.x,"\\\"",""))
#                     ) %>% 
#                     purrr::map_chr(~
#                                      paste0(" - ",
#                                             .x %>% 
#                                               purrr::map_chr(~{
#                                                 ifelse(.x %in% auth_nm_matches_chr,
#                                                        auth_nm_tag_1L_chr,
#                                                        .x)
#                                               }), 
#                                             collapse = "\n"))) %>%
#     add_unique_talk_ref_to_talks_df() 
#   entries_ls <- purrr::pmap(talks_df,
#                             ~{
#                               ABSTRACT_PLACEHOLDER <- ""#..7
#                               ALL_DAY_LGL_PLACEHOLDER <- ..8
#                               AUTHOR_PLACEHODER <- ..2
#                               EVENT_PLACEHOLDER <- ..3
#                               EVENT_URL_PLACEHOLDER <- ""#..9
#                               LOCATION_PLACEHOLDER <- ..4
#                               IMG_CAPTION_PLACEHOLDER <- ""#..10
#                               DATE_START_PLACEHOLDER <- ..17 %>% stringr::str_replace_all("\\\"","")
#                               URL_SLIDES_PLACEHOLDER <- ""#..12
#                               URL_PDF_PLACEHOLDER <- ""#..13
#                               URL_CODE_PLACEHOLDER <- ""#..14
#                               URL_VIDEO_PLACEHOLDER <- ..15
#                               SUMMARY_PLACEHOLDER <- ""#..7
#                               TITLE_PLACEHOLDER <- ..1
#                               PUBLISH_DATE_PLACEHOLDER <- ..6
#                               KEYWORDS_PLACEHOLDER <- ..19 %>% stringr::str_replace_all("\\\"","") 
#                               DESCRIPTION_PLACEHOLDER <- ..16 %>% stringr::str_replace_all("\\\"","")
#                               talk_entry_chr <- purrr::map_chr(tmpl_talk_md_chr, ~ {
#                                 c("ABSTRACT_PLACEHOLDER","ALL_DAY_LGL_PLACEHOLDER","AUTHOR_PLACEHODER",
#                                   "EVENT_PLACEHOLDER","EVENT_URL_PLACEHOLDER","LOCATION_PLACEHOLDER",
#                                   "IMG_CAPTION_PLACEHOLDER", "DATE_START_PLACEHOLDER","URL_SLIDES_PLACEHOLDER",
#                                   "URL_PDF_PLACEHOLDER", "URL_CODE_PLACEHOLDER", "URL_VIDEO_PLACEHOLDER",
#                                   "SUMMARY_PLACEHOLDER", "TITLE_PLACEHOLDER","PUBLISH_DATE_PLACEHOLDER",
#                                   "KEYWORDS_PLACEHOLDER","DESCRIPTION_PLACEHOLDER") %>% purrr::reduce(.init = .x,
#                                                                                                       ~ stringr::str_replace_all(.x,
#                                                                                                                                  .y,
#                                                                                                                                  eval(parse(text=.y))
#                                                                                                       ))
#                                 
#                               }) 
#                               index_1L_int <- stringr::str_locate(talk_entry_chr, "# No Keywords") %>% 
#                                 tibble::as_tibble() %>% 
#                                 dplyr::mutate(index_int = 1:length(talk_entry_chr)) %>% 
#                                 na.omit() %>% dplyr::pull(index_int)
#                               if(!identical(integer(0),index_1L_int))
#                                 talk_entry_chr[index_1L_int-1] <- "# tags:"
#                               talk_entry_chr
#                               #
#                             }) %>%
#     stats::setNames(talks_df$unique_talk_ref_nms_chr)
#   return(entries_ls)
# }