---
title: "Access data in the Australian Mental Health Systems Models Dataverse repository."
authors: 
- Matthew Hamilton
date: 2022-08-28T21:13:14-05:00
banner: img/banners/openminddv.png
categories: 
- Resources for Modellers
- Tutorials
tags: 
- R
- Repositories
- Repositories (Data)
output: hugodown::md_document
autonumbering: true
rmd_hash: 39bf1fbe91b032e2

---

# 1. Objectives

In this tutorial we will:

1.  Briefly describe the concepts relating to the Australian Mental Health Systems Models Dataverse repository; and

2.  Outline the steps required to search for and download files contained in repository datasets using two alternative approaches;

    -   Using a web based interface (very simple, suitable for low volume requests where reproducibility is not required); and
    -   Using R commands (an approach that requires a little more up-front learning, but which can be used in automated and reproducible workflows)

# 2. Concepts

Information about how to install.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/summary.html'>summary</a></span><span class='o'>(</span><span class='nv'>cars</span><span class='o'>)</span></span><span><span class='c'>#&gt;      speed           dist       </span></span>
<span><span class='c'>#&gt;  Min.   : 4.0   Min.   :  2.00  </span></span>
<span><span class='c'>#&gt;  1st Qu.:12.0   1st Qu.: 26.00  </span></span>
<span><span class='c'>#&gt;  Median :15.0   Median : 36.00  </span></span>
<span><span class='c'>#&gt;  Mean   :15.4   Mean   : 42.98  </span></span>
<span><span class='c'>#&gt;  3rd Qu.:19.0   3rd Qu.: 56.00  </span></span>
<span><span class='c'>#&gt;  Max.   :25.0   Max.   :120.00</span></span><span></span>
<span><span class='nv'>fit</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/stats/lm.html'>lm</a></span><span class='o'>(</span><span class='nv'>dist</span> <span class='o'>~</span> <span class='nv'>speed</span>, data <span class='o'>=</span> <span class='nv'>cars</span><span class='o'>)</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>fit</span></span><span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Call:</span></span>
<span><span class='c'>#&gt; lm(formula = dist ~ speed, data = cars)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Coefficients:</span></span>
<span><span class='c'>#&gt; (Intercept)        speed  </span></span>
<span><span class='c'>#&gt;     -17.579        3.932</span></span></code></pre>

</div>

# Worked example

Some simple code to demonstrate how to use it.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/graphics/par.html'>par</a></span><span class='o'>(</span>mar <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0</span>, <span class='m'>1</span>, <span class='m'>0</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://rdrr.io/r/graphics/pie.html'>pie</a></span><span class='o'>(</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>280</span>, <span class='m'>60</span>, <span class='m'>20</span><span class='o'>)</span>,</span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>'Sky'</span>, <span class='s'>'Sunny side of pyramid'</span>, <span class='s'>'Shady side of pyramid'</span><span class='o'>)</span>,</span>
<span>  col <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>'#0292D8'</span>, <span class='s'>'#F7EA39'</span>, <span class='s'>'#C4B632'</span><span class='o'>)</span>,</span>
<span>  init.angle <span class='o'>=</span> <span class='o'>-</span><span class='m'>50</span>, border <span class='o'>=</span> <span class='kc'>NA</span></span>
<span><span class='o'>)</span></span></code></pre>

<div class="figure" style="text-align: center">

<img src="figs/pie-1.png" alt="A fancy pie chart." width="700px" />
<p class="caption">
A fancy pie chart.
</p>

</div>

</div>

