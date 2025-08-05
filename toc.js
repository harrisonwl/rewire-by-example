// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item affix "><a href="rewire-by-example.html">ReWire by Example</a></li><li class="chapter-item "><a href="chapters/chapter0/prequisites.html"><strong aria-hidden="true">1.</strong> Prerequisites</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="chapters/chapter0/haskell.html"><strong aria-hidden="true">1.1.</strong> Haskell</a></li><li class="chapter-item "><a href="chapters/chapter0/monadwrangling/monadwrangling.html"><strong aria-hidden="true">1.2.</strong> Monads in Haskell</a></li></ol></li><li class="chapter-item "><a href="chapters/chapter1/helloworlds.html"><strong aria-hidden="true">2.</strong> Hello Worlds in ReWire</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="chapters/chapter1/simplemealy.html"><strong aria-hidden="true">2.1.</strong> Simple Mealy</a></li><li class="chapter-item "><a href="chapters/chapter1/fibonacci.html"><strong aria-hidden="true">2.2.</strong> Fibonacci, of course</a></li><li class="chapter-item "><a href="chapters/chapter1/carrysaveadders.html"><strong aria-hidden="true">2.3.</strong> Carry Save Adders</a></li></ol></li><li class="chapter-item "><a href="chapters/salsa20/front.html"><strong aria-hidden="true">3.</strong> Cryptographic Hardware in ReWire</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="chapters/salsa20/semantics.html"><strong aria-hidden="true">3.1.</strong> Reference Semantics</a><a class="toggle"><div>❱</div></a></li><li><ol class="section"><li class="chapter-item "><a href="chapters/salsa20/introduction.html"><strong aria-hidden="true">3.1.1.</strong> Introduction</a></li><li class="chapter-item "><a href="chapters/salsa20/words.html"><strong aria-hidden="true">3.1.2.</strong> Words</a></li><li class="chapter-item "><a href="chapters/salsa20/quarterround.html"><strong aria-hidden="true">3.1.3.</strong> The quarterround function</a></li><li class="chapter-item "><a href="chapters/salsa20/rowround.html"><strong aria-hidden="true">3.1.4.</strong> The rowround function</a></li><li class="chapter-item "><a href="chapters/salsa20/columnround.html"><strong aria-hidden="true">3.1.5.</strong> The columnround function</a></li><li class="chapter-item "><a href="chapters/salsa20/doubleround.html"><strong aria-hidden="true">3.1.6.</strong> The doubleround function</a></li><li class="chapter-item "><a href="chapters/salsa20/littleendian.html"><strong aria-hidden="true">3.1.7.</strong> The littleendian function</a></li><li class="chapter-item "><a href="chapters/salsa20/hashfunction.html"><strong aria-hidden="true">3.1.8.</strong> Salsa20 Hash function</a></li><li class="chapter-item "><a href="chapters/salsa20/expansionfunction.html"><strong aria-hidden="true">3.1.9.</strong> Salsa20 Expansion function</a></li><li class="chapter-item "><a href="chapters/salsa20/encryption.html"><strong aria-hidden="true">3.1.10.</strong> Salsa20 Encryption function</a></li></ol></li></ol></li><li class="chapter-item "><a href="chapters/pipelining/pipelining.html"><strong aria-hidden="true">4.</strong> Pipelining in ReWire</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
