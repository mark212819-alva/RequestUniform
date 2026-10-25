<template>
  <div class="table-wrap">
    <table>
      <thead><tr><th>Reference</th><th v-if="showStudent">Student</th><th>Items</th><th>Status</th><th>Submitted</th><th><span class="sr-only">Action</span></th></tr></thead>
      <tbody>
        <tr v-for="request in rows" :key="request.id" @click="$emit('select',request)">
          <td><div class="reference"><span class="request-icon"><ion-icon :icon="receiptOutline"/></span><div><b>{{request.reference}}</b><small>Uniform request</small></div></div></td>
          <td v-if="showStudent"><div class="student"><span>{{initials(request.studentName)}}</span><div><b>{{request.studentName||'Student'}}</b><small>{{request.studentId}}</small></div></div></td>
          <td><span class="item-count">{{itemCount(request)}}</span><small>{{itemCount(request)===1?'item':'items'}}</small></td>
          <td><span class="status-pill" :data-status="request.status"><i></i>{{request.status}}</span></td>
          <td><b class="date">{{formatDate(request.createdAt)}}</b><small>{{formatTime(request.createdAt)}}</small></td>
          <td class="action-cell"><button class="view-button" @click.stop="$emit('select',request)">View details <ion-icon :icon="chevronForwardOutline"/></button></td>
        </tr>
        <tr v-if="!rows.length" class="empty-row"><td :colspan="showStudent?6:5"><div><ion-icon :icon="searchOutline"/><b>No requests found</b><span>Try changing your search or status filter.</span></div></td></tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import{computed}from'vue';
import{IonIcon}from'@ionic/vue';
import{chevronForwardOutline,receiptOutline,searchOutline}from'ionicons/icons';
import{portal}from'../stores/portal';
import type{UniformRequest}from'../app/models';
defineProps<{rows:UniformRequest[]}>();
defineEmits<{select:[request:UniformRequest]}>();
const showStudent=computed(()=>portal.user.value?.role==='marketing');
const itemCount=(request:UniformRequest)=>request.items.reduce((total,item)=>total+item.quantity,0);
const initials=(name:string)=>name?.split(/\s+/).filter(Boolean).map(part=>part[0]).slice(0,2).join('').toUpperCase()||'ST';
const formatDate=(value:string)=>new Intl.DateTimeFormat('en-PH',{month:'short',day:'numeric',year:'numeric'}).format(new Date(value));
const formatTime=(value:string)=>new Intl.DateTimeFormat('en-PH',{hour:'numeric',minute:'2-digit'}).format(new Date(value));
</script>

<style scoped>
.table-wrap{overflow-x:auto}table{width:100%;border-collapse:collapse;min-width:850px}th{padding:12px 14px;text-align:left;color:#8a968f;font-size:9px;letter-spacing:1.15px;text-transform:uppercase;background:#fbfcfb;border-bottom:1px solid #e8edea}td{padding:15px 14px;border-bottom:1px solid #edf1ee;color:#526159;font-size:12px;vertical-align:middle}tbody tr:not(.empty-row){cursor:pointer;transition:background .15s ease}tbody tr:not(.empty-row):hover{background:#f7fbf9}tbody tr:last-child td{border-bottom:0}td b,td small{display:block}td b{color:#24372d}td small{font-size:10px;color:#8a968f;margin-top:3px}.reference,.student{display:flex;align-items:center;gap:10px}.request-icon{width:34px;height:34px;border-radius:9px;background:#e9f6ef;color:#087a46;display:grid;place-items:center;font-size:17px}.student>span{width:32px;height:32px;border-radius:50%;background:#eef3f0;color:#47705c;display:grid;place-items:center;font-size:9px;font-weight:900}.item-count{display:inline-grid;place-items:center;min-width:28px;height:28px;padding:0 8px;border-radius:8px;background:#f0f4f2;color:#294437;font-weight:800}.status-pill{display:inline-flex;align-items:center;gap:7px;padding:6px 9px;border-radius:99px;font-size:10px;font-weight:800;background:#eef2f0;color:#53645b;white-space:nowrap}.status-pill i{width:6px;height:6px;border-radius:50%;background:currentColor}.status-pill[data-status="Pending"]{background:#fff5d9;color:#956500}.status-pill[data-status="Under Review"],.status-pill[data-status="Preparing"]{background:#eaf2fb;color:#2b68a0}.status-pill[data-status="Approved"],.status-pill[data-status="Ready for Pickup"],.status-pill[data-status="Completed"]{background:#e8f6ee;color:#087346}.status-pill[data-status="Rejected"],.status-pill[data-status="Cancelled"]{background:#ffeded;color:#ad3636}.date{font-size:11px}.action-cell{text-align:right}.view-button{display:inline-flex;align-items:center;gap:5px;border:1px solid #cfe1d7;background:#fff;color:#087346;border-radius:8px;padding:8px 10px;font-size:10px;font-weight:800;cursor:pointer}.view-button:hover{background:#087a46;border-color:#087a46;color:#fff}.empty-row td{padding:55px 20px}.empty-row div{display:flex;flex-direction:column;align-items:center;color:#87948d}.empty-row ion-icon{font-size:28px;margin-bottom:9px;color:#9db1a6}.empty-row b{font-size:13px}.empty-row span{font-size:11px;margin-top:4px}.sr-only{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0)}
</style>
