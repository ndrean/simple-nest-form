const fetchPosts = (tag) => {
  document.querySelector(tag).addEventListener("click", (e) => {
    e.preventDefault();
    fetch('/posts?f=""', {
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Content-Type": "text/html",
        Accept: "text/html",
      },
      credentials: "same-origin",
    })
      .then((response) => response.text())
      .then(
        (content) => (document.querySelector("#posts_list").innerHTML = content)
      );
  });
};

export { fetchPosts };
