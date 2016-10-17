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

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import java.util.UUID;

/**
 * The <code>ISurveyService</code> interface defines the functionality that must be
 * provided by a Survey Service implementation.
 *
 * @author Marcus Portmann
 */
public interface ISurveyService
{
  /**
   * Retrieve the survey definition identified by the specified ID.
   *
   * @param id      the Universally Unique Identifier (UUID) used, along with the version of the
   *                survey definition, to uniquely identify the survey definition
   * @param version the version of the survey definition
   *
   * @return the survey definition identified by the specified ID and version or <code>null</code>
   *         if the survey definition could not be found
   */
  SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException;

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   *
   * @throws SurveyServiceException
   */
  SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException;
}
