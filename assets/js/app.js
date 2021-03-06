// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

import 'bootstrap';
import $ from 'jquery';
window.jQuery = $;
window.$ = $;

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

import {Socket} from "phoenix";
import LiveSocket from "phoenix_live_view";
import NProgress from "nprogress";

import hljs from 'highlight.js';
hljs.initHighlightingOnLoad();

let Hooks = {};

function hljs_init() {
    document.querySelectorAll('pre code').forEach((block) => {
        hljs.highlightBlock(block);
    });
}

Hooks.HighlightCode = {
    mounted() { hljs_init(); },
    updated() { hljs_init(); }
}

let scrollAt = () => {
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
    let clientHeight = document.documentElement.clientHeight

    return scrollTop / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
    page() { return this.el.dataset.page },
    mounted(){
        this.pending = this.page()
        window.addEventListener("scroll", e => {
            if(this.pending == this.page() && scrollAt() > 90){
                this.pending = this.page() + 1
                this.pushEvent("load-more", {})
            }
        })
    },
    updated(){ this.pending = this.page() },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}});
window.addEventListener('phx:page-loading-start', info => NProgress.start());
window.addEventListener('phx:page-loading-stop', info => NProgress.done());
liveSocket.connect();
window.liveSocket = liveSocket;

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

$(".alert").delay(4000).slideUp(200, function() {
    $(this).alert('close');
});

