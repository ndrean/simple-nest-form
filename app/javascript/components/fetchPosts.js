const fetchPosts = (tag) => {
  document.querySelector(tag).addEventListener("click", async (e) => {
    e.preventDefault();
    try {
      const query = await fetch('/posts?f=""', {
        method: "GET",
        headers: {
          "Content-Type": "text/html",
          Accept: "text/html",
        },
        credentials: "same-origin", // default value
      });
      if (query.ok) {
        const content = await query.text();
        return (document.querySelector("#posts_list").innerHTML = content);
      }
    } catch (error) {
      throw error;
    }
  });
};

export { fetchPosts };
