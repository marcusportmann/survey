/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.ejb.Schedule;
import javax.ejb.Singleton;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.inject.Inject;

/**
 * The <code>BackgroundSurveyRequestSenderTimer</code> class implements the timer for the Background
 * Survey Request Sender.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("unused")
@Singleton
@TransactionManagement(TransactionManagementType.BEAN)
public class BackgroundSurveyRequestSenderTimer
{
  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * Send the survey requests.
   */
  @Schedule(hour = "*", minute = "*", second = "*/30", persistent = false)
  public void sendSMSs()
  {
    surveyService.sendSurveyRequests();
  }
}
