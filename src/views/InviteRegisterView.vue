<template>
  <ion-page>
    <ion-content :fullscreen="true" class="invite-content">
      <main class="invite-page">
        <section class="invite-card">
          <div class="mark"><ion-icon :icon="role==='student'?schoolOutline:peopleOutline"/></div>
          <p class="eyebrow">{{role==='student'?'STUDENT':'MARKETING OFFICE'}} INVITATION</p>
          <h1>Create your account</h1>
          <p class="intro">Complete the form to register through this authorized invitation link.</p>
          <form @submit.prevent="submit">
            <div class="name-grid"><label>First name<input v-model="firstName" required autocomplete="given-name"/></label><label>Last name<input v-model="lastName" required autocomplete="family-name"/></label></div>
            <label>{{role==='student'?'Student ID':'Employee ID'}}<input v-model="identifier" required autocomplete="username"/></label>
            <label>{{role==='student'?'PHINMA email':'Official email'}}<input v-model="email" required type="email" autocomplete="email"/></label>
            <label>Password<input v-model="password" required type="password" minlength="8" autocomplete="new-password"/></label>
            <label>Confirm password<input v-model="confirmPassword" required type="password" minlength="8" autocomplete="new-password"/></label>
            <p v-if="message" :class="success?'success':'error'">{{message}}</p>
            <ion-button expand="block" type="submit" :disabled="loading||success"><ion-spinner v-if="loading"/><span v-else>{{success?'Account created':'Create account'}}</span></ion-button>
          </form>
          <router-link v-if="success" class="login-link" :to="`/${role}/login`">Continue to {{role==='student'?'Student':'Marketing'}} login</router-link>
          <p class="secure"><ion-icon :icon="shieldCheckmarkOutline"/> This shared link remains available until it expires or is revoked.</p>
        </section>
      </main>
    </ion-content>
  </ion-page>
</template>

<script setup lang="ts">
import{computed,ref}from'vue';
import{useRoute}from'vue-router';
import{IonButton,IonContent,IonIcon,IonPage,IonSpinner}from'@ionic/vue';
import{peopleOutline,schoolOutline,shieldCheckmarkOutline}from'ionicons/icons';
import{createClient}from'@supabase/supabase-js';
import type{Role}from'../app/models';
const route=useRoute(),role=computed(()=>route.params.role as Role),identifier=ref(''),firstName=ref(''),lastName=ref(''),email=ref(''),password=ref(''),confirmPassword=ref(''),loading=ref(false),message=ref(''),success=ref(false);
const supabase=createClient(import.meta.env.VITE_SUPABASE_URL,import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY,{auth:{persistSession:false}});
async function submit(){if(password.value!==confirmPassword.value){message.value='Passwords do not match.';return}loading.value=true;message.value='';try{const{data,error}=await supabase.functions.invoke('invite-register',{body:{token:String(route.params.token),role:role.value,identifier:identifier.value,firstName:firstName.value,lastName:lastName.value,email:email.value,password:password.value}});if(error){let detail='Unable to use this invitation.';try{const body=await error.context?.json();if(body?.error)detail=body.error}catch{}throw new Error(detail)}if(!data?.ok)throw new Error(data?.error||'Unable to create the account.');success.value=true;message.value=`Account created. Your ${role.value==='student'?'Student':'Employee'} ID is ${data.identifier}.`}catch(e){message.value=e instanceof Error?e.message:'Unable to create the account.'}finally{loading.value=false}}
</script>

<style scoped>
.invite-content{--background:#f6f8f7}.invite-page{min-height:100%;display:grid;place-items:center;padding:28px;background:radial-gradient(circle at top,#eaf6ef,#f6f8f7 45%)}.invite-card{width:min(100%,920px);background:#fff;border:1px solid #dfe8e2;border-radius:20px;padding:38px 42px;box-shadow:0 20px 65px #173b2920}.mark{width:54px;height:54px;border-radius:15px;background:#087a46;color:#fff;display:grid;place-items:center;font-size:26px;margin-bottom:20px}.eyebrow{color:#087a46;font-size:10px;font-weight:900;letter-spacing:1.7px}.invite-card h1{font-size:31px;margin:0 0 8px}.intro{color:#718078;margin:0 0 25px}.invite-card form{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:17px 20px}.name-grid{grid-column:1/-1;display:grid;grid-template-columns:1fr 1fr;gap:20px}.invite-card label{display:grid;gap:7px;color:#35483e;font-size:12px;font-weight:750}.invite-card input{width:100%;height:47px;border:1px solid #d8e3dc;border-radius:10px;padding:0 12px;font:inherit;outline:none}.invite-card input:focus{border-color:#087a46;box-shadow:0 0 0 3px #087a4615}.invite-card form>p,.invite-card form>ion-button{grid-column:1/-1}.error,.success{padding:11px 12px;border-radius:9px;font-size:12px;margin:0}.error{background:#fff0f0;color:#a52f2f}.success{background:#eaf7ef;color:#087346}.login-link{display:block;text-align:center;margin-top:18px;color:#087a46;font-weight:800;text-decoration:none}.secure{display:flex;align-items:center;justify-content:center;gap:7px;margin:22px 0 0;color:#849088;font-size:10px}@media(max-width:680px){.invite-page{display:block;min-height:100%;padding:max(12px,env(safe-area-inset-top)) 12px max(24px,env(safe-area-inset-bottom))}.invite-card{padding:24px 18px;border-radius:16px}.invite-card form,.name-grid{grid-template-columns:1fr}.name-grid{grid-column:auto}.invite-card form>p,.invite-card form>ion-button{grid-column:auto}.invite-card input{font-size:16px}.secure{line-height:1.45;text-align:center}}
</style>
