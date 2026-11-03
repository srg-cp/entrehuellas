import { recovery,recoveryError } from '../../utils/recovery';
export default defineEventHandler(async event => { try { return await (await recovery(event)).targets.execute(getQuery(event).qr === undefined ? undefined : String(getQuery(event).qr)); } catch(e) { return recoveryError(event,e); } });
