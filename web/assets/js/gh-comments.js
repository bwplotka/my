jQuery(function($) {
    const repo = "my";
    const owner = "bwplotka";
    const commentCharsLimit = 100;

    'use strict';
    let _Blog = window._Blog || {};

    _Blog.renderComment = function(issue) {
        // TODO(bwplotka): Use some templating instead?
        let comment = $("<div/>");
        comment.addClass("post-gh-comment");

        // TODO(bwplotka): Limit number of lines?
        let body = $("<a/>");

        let text = issue.body.substring(0, commentCharsLimit);
        if (issue.body.length >= commentCharsLimit) {
            text += "...";
        }
        body.text(text);
        src.attr("href", issue.html_url);

        let author = $("<a/>");
        author.text(issue.user.login);
        author.attr("href", issue.user.html_url);

        comment.append(body);

        let commentFooter = $("<div/>");
        commentFooter.addClass("post-gh-comment-footer");
        commentFooter.append("<time datetime=" + issue.updated_at + ">"+issue.updated_at +"</time>");
        commentFooter.append(" | <span>Author: ");
        commentFooter.append(author);
        commentFooter.append(" | Responses: ", issue.comments, "</span>");

        comment.append(commentFooter);

        $('.post-gh-comments').append(comment);
        _Blog.issues[issue.id] = true
    };
    _Blog.loadPostComments = function() {
        $('.post-gh-comments-loading').text("Loading...");
        _Blog.octokit.issues.listForRepo({
            owner: owner,
            repo: repo,
            state: 'all',
            labels: _Blog.name + ",comment",
            sort: 'created',
            direction: 'asc'
        }).then(({data, headers, status}) => {
            if (status !== 200) {
                console.log("failed to load issues:", status, data);
                return
            }
            console.log(_Blog.name);
            console.log(data);
            for (let i = 0; i < data.length; i++) {
                if (data[i].id in _Blog.issues) {
                    continue
                }
                _Blog.renderComment(data[i])
            }
            $('.post-gh-comments-loading').text("");
        })
    };

    $(document).ready(function() {
        _Blog.name = $('article').attr('id');
        _Blog.octokit = new Octokit();
        _Blog.issues={};
        _Blog.loadPostComments();
        setInterval(_Blog.loadPostComments, 10000);
    });
});