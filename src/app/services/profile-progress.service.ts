import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ProfileTracker } from '../interfaces/ProfileResponse';
import { HttpServiceService } from './http-service.service';

@Injectable({
  providedIn: 'root',
})
export class ProfileProgressService {
 // private apiUrl = "http://52.15.152.26:5555/"
  constructor(private http: HttpClient, private service: HttpServiceService) {}
  getProfileCompletion(userId: number,): Observable<ProfileTracker> {
    return this.http.get<ProfileTracker>(`${this.service.serverUrl}profile-progress/get/`+userId);
  }
}
