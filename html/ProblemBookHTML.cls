% ==============================================================================
%  ProblemBookHTML.cls -- HTML (lwarp) variant of ProblemBook.cls (Field Theory problems).
%  The print class is NOT touched. Chapters stay identical: only what HTML needs is defined here --
%  lwarp first, then the maths / colours / tikz styles of the print version and simple HTML blocks for the boxes, examples and problems.
% ==============================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ProblemBookHTML}[2026/11/23 lwarp variant of ProblemBook (Field Theory)]
\LoadClass[onecolumn,twoside]{book}
\RequirePackage{iftex}
\RequirePackage{etoolbox}
% ---- lwarp must be loaded before other packages --------------------------------
\RequirePackage[HTMLFilename={ch},mathjax]{lwarp}
\boolfalse{FileSectionNames}
\setcounter{FileDepth}{0}        % one HTML page per chapter
\setcounter{tocdepth}{1}
\setcounter{secnumdepth}{2}
\HTMLLanguage{uk}
\makeatletter\AtBeginDocument{\def\LWR@printchaptername{}}\makeatother   % chapter heading: only the number
\CSSFilename{conspect.css}   % styles of the boxes; the file lies in html/assets/ and is published to assets/

% ---- language and fonts (fonts matter only for images made by lateximage) ------
\RequirePackage{fontspec}
\IfFontExistsTF{stix}{\setmainfont{stix}}{\setmainfont{FreeSerif}}
\IfFontExistsTF{CMU Sans Serif}{\setsansfont{CMU Sans Serif}}{\setsansfont{FreeSans}}
% lwarp types the HTML tags in the monospace font; programming ligatures would put a stray ^ before them
\IfFontExistsTF{JetBrains Mono}{\setmonofont{JetBrains Mono}[RawFeature={-calt,-liga}]}{\setmonofont{FreeMono}}
\defaultfontfeatures{Ligatures={TeX}}
\RequirePackage[english,russian,ukrainian]{babel}
\RequirePackage[unicode]{hyperref}   % lwarp patches it
\RequirePackage{csquotes}
\RequirePackage[dvipsnames,svgnames,table]{xcolor}
\newcommand{\Annabelle}{\itshape}    % decorative font is print-only
\newif\ifappendix \newif\ifanswers \newif\iftoc \newif\ifbibliography \newif\ifintro
\def\emphz#1{{\itshape\color{blue!80!black} #1}}

%===============================================================================
%  Maths: as in the print class (LaTeX / lateximage); MathJax gets its copy through lwarp-mathjax.tex
%===============================================================================
\RequirePackage[math-style=TeX,bold-style=TeX]{unicode-math}
\RequirePackage{amsmath}
\IfFontExistsTF{Stix Two Math}{\setmathfont[math-style=TeX]{Stix Two Math}}{\setmathfont{Latin Modern Math}}
\RequirePackage{esint}
\RequirePackage{nicefrac}\let\nfrac\nicefrac
\input{html/mathmacros.tex}
\AtBeginDocument{\let\pot\phi \let\phi\varphi \let\epsilon\varepsilon}
\newcommand{\tcbhighmath}[1]{\boxed{#1}}
\RequirePackage[version=4]{mhchem}
\providecommand{\printindex}[1][]{}
\RequirePackage{tabularray}\UseTblrLibrary{booktabs}
% tabularray is not supported by lwarp -> a tblr that prepare_html.py cannot convert becomes an image
\AtBeginDocument{\preto\tblr{\begin{lateximage}[table]}\appto\endtblr{\end{lateximage}}}
\AtBeginDocument{\preto\longtblr{\begin{lateximage}[table]}\appto\endlongtblr{\end{lateximage}}}
\RequirePackage{booktabs,multirow,array,tabularx,colortbl}   % tabularx: HTML replacement of tblr (prepare_html.py)
\RequirePackage{varwidth}
\newcolumntype{R}{>{\footnotesize}r}
\newcolumntype{L}{>{\footnotesize}l}
\newcolumntype{M}[1]{>{\begin{varwidth}[t]{#1}}l<{\end{varwidth}}}
\newcommand{\centercell}[1]{\multicolumn{1}{c}{#1}}
\newcommand{\specialcell}[3][c]{\begin{tabular}[#1]{@{}#2@{}}#3\end{tabular}}
\RequirePackage[justification=centering,labelsep=period]{caption}
\RequirePackage{subcaption}
\renewcommand\thesubfigure{\alph{subfigure}}
\RequirePackage[inline]{enumitem}\setlist{nosep}
\RequirePackage{epigraph}
\setlength\epigraphrule{0pt}
\makeatletter
\def\tabcaption{\def\@captype{table}\caption}
\makeatother
\RequirePackage{currfile}
\ExplSyntaxOn
\NewDocumentCommand{\multiinclude}{ m O{} }
 {\clist_set:Nx \l_Chapters_clist{ #1 }
  \clist_map_inline:Nn \l_Chapters_clist { \IfFileExists{_html/##1/##1#2.tex}{\input{_html/##1/##1#2.tex}}{\InputIfFileExists{##1/##1#2}{}{}}\par}}
\ExplSyntaxOff
% \htmlinput{Additions/Spectra}: like \input, but the fixed copy _html/<path>.tex (prepare_html.py) is read first
\newcommand{\htmlinput}[1]{\IfFileExists{_html/#1.tex}{\input{_html/#1.tex}}{\InputIfFileExists{#1}{}{\ClassWarning{ProblemBookHTML}{#1.tex not found}}}}
\def\schapter#1{\chapter*{#1}\addcontentsline{toc}{chapter}{#1}}
\newcommand{\schapterpage}[1]{\ForceHTMLPage\schapter{#1}}

% ---- TikZ, PGFPlots: as in ProblemBook.cls -------------------------------------
\RequirePackage{tikz, pgfplots, tikz-3dplot}
\usetikzlibrary{decorations.text, decorations.markings, intersections, arrows.meta, shapes, shadows, quotes, angles, shapes.geometric, calc}
\usepgfplotslibrary{fillbetween}
\pgfplotsset{every axis label/.append style={font=\small}, compat=newest}
\tikzset{every picture/.style={font=\small}}
\definecolor{themecolordark}{RGB}{0,46,100}
\definecolor{themecolorlight}{RGB}{0,100,170}

% ---- bibliography (as in ProblemBook.cls, option biblatex) ----
\RequirePackage[backend=biber,bibstyle=gost-numeric,maxnames=10,babel=other,isbn=true,url=false,defernumbers=true]{biblatex}
\DefineBibliographyStrings{ukrainian}{bibliography = {Література}}
\DeclareBibliographyCategory{Textbooks}
\DeclareBibliographyCategory{Problems}
\DeclareFieldFormat{title}{\usebibmacro{string+url}{#1}}
% lwarp's \href takes its URL unexpanded: expand the url field first
\newbibmacro{string+url}[1]{%
  \iffieldundef{url}{#1}{\begingroup\edef\x{\endgroup\noexpand\href{\thefield{url}}}\x{#1}}}
\defbibheading{bibintoc}{\schapterpage{Література}}

% ---- appendices: sections A, B, ... on one page "Додатки" ----
\makeatletter
\let\ProblemOrigAppendix\appendix
\renewcommand\appendix{%
  \ProblemOrigAppendix
  \setcounter{section}{0}%
  \gdef\thesection{\@Alph\c@section}%
  \@addtoreset{table}{section}\@addtoreset{equation}{section}%
  \renewcommand\thetable{\thesection.\@arabic\c@table}%
  \@addtoreset{figure}{section}%
  \renewcommand\thefigure{\thesection.\@arabic\c@figure}%
  \renewcommand\theequation{\thesection.\arabic{equation}}%
  \schapterpage{Додатки}}
\makeatother

%===============================================================================
%  Boxes, examples, problems: simple HTML blocks (styled by CSS classes of conspect.css)
%===============================================================================
\providecommand{\Needspace}[1]{}
\providecommand{\FloatBarrier}{}
% text wrapped around a box (insbox, \InsertBoxR{lines}{box}[opt]): in HTML the box stays in the text, [opt] is dropped
\NewDocumentCommand{\InsertBoxR}{m m o}{#2}
\providecommand{\tocunnum}[1]{}
\NewDocumentEnvironment{Theory}{O{}}{\begin{BlockClass}{cb-theory}\textbf{Теоретичні відомості}\IfValueT{#1}{\ #1}\par}{\end{BlockClass}}
\NewDocumentEnvironment{Attention}{O{} O{red}}{\begin{BlockClass}{cb-attention}}{\end{BlockClass}}
\newcounter{example}
\NewDocumentCommand{\Example}{ O{} +m }{\stepcounter{example}%
  \par\begin{BlockClass}{cb-example}\textbf{Приклад \theexample.}\ #2\end{BlockClass}}
\NewDocumentEnvironment{solutionexample}{+O{} +O{}}{\begin{BlockClass}{cb-solution}\textbf{Розв'язок.}\par}{\end{BlockClass}}
% wrapfigure (text wrapped around a figure) has no HTML meaning -> a normal figure
\newenvironment{wrapfigure}[3][]{\begin{figure}[h]}{\end{figure}}
\newenvironment{wrapstuff}[1][]{\begin{figure}[h]}{\end{figure}}
\RequirePackage{ntheorem}
\theoremstyle{plain}\theoremheaderfont{\bfseries}\theorembodyfont{\normalfont}\theoremseparator{.}
\newtheorem{problemX}{}[chapter]
\newcommand{\theproblem}{\theproblemX}
% answers: the answers package writes them to <Chapter>/<Chapter>-Answers.tex (as in print); they are read on a page
% of their own "Відповіді" (\answers); a problem links to its answer and the answer back to the problem
\RequirePackage{answers}
\Newassociation{solution}{Solution}{answer}
% a problem is a plain block (no ntheorem list: lwarp's <ul><li> of a theorem sometimes came out of pdftotext with the text lines
% in front of the <li>): the number hangs in the left margin, an optional title follows it in brackets
\NewDocumentEnvironment{problem}{o}{\par\refstepcounter{problemX}\begin{BlockClass}{cb-problem}%
  \hypertarget{problem:\theproblem}{}\InlineClass{probnum}{\theproblem.}\ \IfValueT{#1}{(\emph{#1})\ }}%
  {\ifcsname r@solution\theproblem\endcsname\ \hyperlink{solution:\theproblem}{[відповідь]}\fi\end{BlockClass}}
\renewenvironment{Solution}[1]{\begin{BlockClass}{cb-answer}%
  \hypertarget{solution:#1}{}\label{solution#1}\textbf{\hyperlink{problem:#1}{#1.}}\ }{\end{BlockClass}}
\newenvironment{answerbox}{\begin{BlockClass}{cb-answer}}{\end{BlockClass}}
\newcommand{\answers}{\schapterpage{Відповіді}}
% The headings of the answers are \section*{\nameref*{<Chapter>}}: lwarp cannot resolve that (shows "??"). Every \chapter{T}
% remembers its title under the name of the file it is read from (\currfilebase) and \nameref gives it back.
\makeatletter
\AtBeginDocument{%
  \let\CB@chapter\chapter
  \renewcommand\chapter{\@ifstar{\CB@chapter*}{\CB@chaptertitle}}%
  \renewrobustcmd*{\nameref}{\@ifstar\CB@nameref\CB@nameref}}
\newcommand\CB@chaptertitle[1]{\expandafter\gdef\csname CB@title@\currfilebase\endcsname{#1}\CB@chapter{#1}}
\newcommand\CB@nameref[1]{\ifcsname CB@title@#1\endcsname\csname CB@title@#1\endcsname\else ??\fi}
\makeatother

% \url inside a \caption is a "moving argument" for lwarp: a robust version
\AtBeginDocument{\DeclareRobustCommand{\url}[1]{\href{#1}{#1}}}

% ---- MathJax and pictures ----
% inside HTML-mode pictures '$' is active (MathJax); tikz calc ($..$) needs it to be a math shift
\begin{warpHTML}
\preto\pgfpicture{\catcode`\$=3 }
\end{warpHTML}
% \htmlpicture{file.svg}: a picture built by prepare_html.py (SVG works only in HTML mode)
\newcommand{\htmlpicture}[1]{\fbox{figure}}
\begin{warpHTML}
\renewcommand{\htmlpicture}[1]{\includegraphics{#1}}
\end{warpHTML}
\begin{warpHTML}
\AtBeginDocument{\renewcommand{\phantomsection}{}}
\end{warpHTML}
\InputIfFileExists{lwarp-tikzdefs.tex}{}{}
\InputIfFileExists{lwarp-mathjax.tex}{}{\ClassWarning{ProblemBookHTML}{lwarp-mathjax.tex not found: formulas with your macros will be red in HTML}}
\endinput
