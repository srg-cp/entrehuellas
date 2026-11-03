<script setup lang="ts">
import '../styles/home.css';
</script>

<template>
  <h1 class="home-title" aria-label="Su regreso empieza contigo">Su regreso<br><span>empieza contigo</span></h1>

  <GlassSurface as="section" class="home-banner home-report" aria-labelledby="home-report-title">
    <div class="home-scenery" aria-hidden="true">
      <img src="/images/home/report-reunion.webp" width="1024" height="1024" alt="" fetchpriority="high" />
    </div>
    <NavigationLink to="/mis-mascotas" class="home-pets-link">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 17c0-2 2-5 4-5s4 3 4 5c0 3-3 2-4 2s-4 1-4-2Z" /><ellipse cx="5" cy="9" rx="2" ry="2.5" /><ellipse cx="10" cy="5" rx="2" ry="2.5" /><ellipse cx="16" cy="6" rx="2" ry="2.5" /><ellipse cx="20" cy="11" rx="2" ry="2.5" /></svg>
      <span>Mis mascotas</span><span aria-hidden="true">→</span>
    </NavigationLink>
    <h2 id="home-report-title" class="home-report-copy">Ayudemos a que vuelva a casa.</h2>
    <NavigationLink to="/reportar" origin class="home-banner-action">
      <span>Reportar pérdida</span>
      <svg class="home-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6" /></svg>
    </NavigationLink>
  </GlassSurface>

  <GlassSurface as="section" class="home-banner home-found" aria-labelledby="home-found-title">
    <img class="home-found-art" src="/images/home/found-home.webp" width="1024" height="683" alt="" loading="lazy" decoding="async" />
    <div class="home-found-content">
      <h2 id="home-found-title">¿Encontraste una <span>mascota?</span></h2>
      <p>Ayúdala a volver a casa.</p>
      <NavigationLink to="/reportar?tipo=hallazgo" origin class="home-banner-action">
        <span>Encontré una mascota</span>
        <svg class="home-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6" /></svg>
      </NavigationLink>
    </div>
  </GlassSurface>

  <GlassSurface class="home-banner home-photo">
    <NavigationLink to="/coincidencias" origin class="home-photo-link">
      <svg class="home-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6" /></svg>
      <img src="/images/home/photo-search.webp" width="720" height="540" alt="" loading="lazy" decoding="async" />
      <span>Buscar con una foto</span>
    </NavigationLink>
  </GlassSurface>

  <GlassSurface as="section" class="home-banner home-explore" aria-labelledby="home-explore-title">
    <div class="home-explore-art" aria-hidden="true">
      <img src="/images/home/explore-map.webp" width="1024" height="683" alt="" loading="lazy" decoding="async" />
      <span class="home-explore-mark" />
    </div>
    <div class="home-explore-content">
      <h2 id="home-explore-title">Explora <span>cerca de ti</span></h2>
      <p>Cada mirada puede ayudar.</p>
      <NavigationLink to="/explorar" class="home-banner-action">
        <span>Explorar</span>
        <svg class="home-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 12h16m-6-6 6 6-6 6" /></svg>
      </NavigationLink>
    </div>
  </GlassSurface>
</template>
