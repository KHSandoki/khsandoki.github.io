/* Gallery lightbox. No dependencies.
   Any .gallery button on the page joins one shared, keyboard-navigable set. */
(function () {
  "use strict";

  var triggers = Array.prototype.slice.call(
    document.querySelectorAll(".gallery button[data-full]")
  );
  if (!triggers.length) return;

  var index = 0;
  var lastFocused = null;

  var box = document.createElement("div");
  box.className = "lb";
  box.setAttribute("role", "dialog");
  box.setAttribute("aria-modal", "true");
  box.setAttribute("aria-label", "Image viewer");
  box.innerHTML =
    '<button class="lb-btn lb-close" type="button" aria-label="Close">&times;</button>' +
    '<button class="lb-btn lb-prev" type="button" aria-label="Previous image">&#8249;</button>' +
    '<button class="lb-btn lb-next" type="button" aria-label="Next image">&#8250;</button>' +
    "<figure><img alt=\"\"><figcaption></figcaption></figure>";
  document.body.appendChild(box);

  var img = box.querySelector("img");
  var cap = box.querySelector("figcaption");
  var btnClose = box.querySelector(".lb-close");
  var btnPrev = box.querySelector(".lb-prev");
  var btnNext = box.querySelector(".lb-next");

  // A single image needs no stepping controls.
  if (triggers.length < 2) {
    btnPrev.hidden = true;
    btnNext.hidden = true;
  }

  function show(i) {
    index = (i + triggers.length) % triggers.length;
    var t = triggers[index];
    img.src = t.getAttribute("data-full");
    img.alt = t.getAttribute("data-alt") || "";
    cap.textContent = t.getAttribute("data-caption") || "";
  }

  function open(i) {
    lastFocused = document.activeElement;
    show(i);
    box.classList.add("is-open");
    document.body.style.overflow = "hidden";
    btnClose.focus();
  }

  function close() {
    box.classList.remove("is-open");
    document.body.style.overflow = "";
    img.src = "";
    if (lastFocused) lastFocused.focus();
  }

  triggers.forEach(function (t, i) {
    t.addEventListener("click", function () {
      open(i);
    });
  });

  btnClose.addEventListener("click", close);
  btnPrev.addEventListener("click", function () {
    show(index - 1);
  });
  btnNext.addEventListener("click", function () {
    show(index + 1);
  });

  // Click the backdrop — but not the figure — to dismiss.
  box.addEventListener("click", function (e) {
    if (e.target === box) close();
  });

  document.addEventListener("keydown", function (e) {
    if (!box.classList.contains("is-open")) return;
    if (e.key === "Escape") close();
    else if (e.key === "ArrowLeft") show(index - 1);
    else if (e.key === "ArrowRight") show(index + 1);
    else if (e.key === "Tab") {
      // Keep focus inside the dialog while it is open.
      e.preventDefault();
      var stops = [btnClose, btnPrev, btnNext].filter(function (b) {
        return !b.hidden;
      });
      var at = stops.indexOf(document.activeElement);
      stops[(at + (e.shiftKey ? -1 : 1) + stops.length) % stops.length].focus();
    }
  });
})();
