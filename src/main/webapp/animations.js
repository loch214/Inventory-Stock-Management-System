
// Theme toggle
function toggleTheme() {
    const body = document.body;
    body.classList.toggle('dark');
    localStorage.setItem('theme', body.classList.contains('dark') ? 'dark' : 'light');
}

// Load theme on page load
document.addEventListener('DOMContentLoaded', () => {
    const theme = localStorage.getItem('theme');
    if (theme === 'dark') {
        document.body.classList.add('dark');
    }

    // Animate panels
    const panels = document.querySelectorAll('.blurred-panel');
    panels.forEach(panel => {
        panel.style.opacity = '0';
        panel.style.transform = 'translateY(20px)';
        setTimeout(() => {
            panel.style.transition = 'opacity 0.5s, transform 0.5s';
            panel.style.opacity = '1';
            panel.style.transform = 'translateY(0)';
        }, 100);
    });
});

// Smooth scroll for sidebar links
document.querySelectorAll('.sidebar nav a').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const href = link.getAttribute('href');
        window.location.href = href;
    });
});
