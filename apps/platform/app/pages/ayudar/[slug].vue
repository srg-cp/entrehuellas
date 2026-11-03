<script setup lang="ts">
import AccountScreen from '../../features/access/presentation/screens/AccountScreen.vue';
import RecoveryScreen from '../../features/recovery/presentation/screens/RecoveryScreen.vue';
const route = useRoute();
const slug = String(route.params.slug || '');
useSeoMeta({ title:'Ayudar en este caso · Entre Huellas', robots:'noindex,nofollow,noarchive' });
</script>
<template><AmbientPageShell><AccountScreen><template #default="{session}"><RecoveryScreen :key="session.actor + slug" :actor="session.actor" section="report" :qr-slug="slug" /></template></AccountScreen></AmbientPageShell></template>
