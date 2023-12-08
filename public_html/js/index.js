window.addEventListener('DOMContentLoaded', () => {
	const sidebar = document.getElementById("sidebar");
	const content = document.getElementsByTagName("body")[0];
	const toc = document.getElementById("table-of-contents");

	const tocBtn = document.getElementById("toc-btn");
	const menuBtn = document.getElementById("menu-btn");

	const b = document.body;

	b.lock = () => {
		b.style.setProperty('--st', -(document.documentElement.scrollTop) + "px");
		b.classList.toggle('lock-scroll');
	}

	tocBtn.addEventListener("click", () => {
		if (sidebar.classList.contains('unhide')) {
			sidebar.classList.toggle("unhide");
		} else {
			b.lock();
		}

		toc.classList.toggle("unhide");
	})

	menuBtn.addEventListener("click", () => {
		if (toc.classList.contains('unhide')) {
			toc.classList.toggle("unhide");
		} else {
			b.lock();
		}

		sidebar.classList.toggle("unhide");
	})

	toc.addEventListener("click", () => {
		if (toc.classList.contains("unhide")) {
			toc.classList.toggle("unhide");
			b.lock();
		}
	})

	sidebar.addEventListener("click", () => {
		if (sidebar.classList.contains("unhide")) {
			sidebar.classList.toggle("unhide");
			b.lock();
		}
	})
})
