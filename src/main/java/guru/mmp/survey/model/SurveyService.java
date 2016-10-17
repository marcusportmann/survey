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

//~--- non-JDK imports --------------------------------------------------------

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.inject.Default;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyService</code> class provides the Survey Service implementation.
 *
 * @author Marcus Portmann
 */
@SuppressWarnings("JpaQlInspection")
@ApplicationScoped
@Default
public class SurveyService
  implements ISurveyService
{
  /* Logger */
  private static final Logger logger = LoggerFactory.getLogger(SurveyService.class);

  /* Entity Manager */
  @PersistenceContext(unitName = "Application")
  private EntityManager entityManager;

  /**
   * Constructs a new <code>SurveyService</code>.
   */
  public SurveyService() {}

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
  public SurveyDefinition getSurveyDefinition(UUID id, int version)
    throws SurveyServiceException
  {
    try
    {
      String getSurveyDefinitionSQL =
          "SELECT st FROM SurveyDefinition st WHERE st.id = :id AND st.version = :version";

      TypedQuery<SurveyDefinition> query = entityManager.createQuery(getSurveyDefinitionSQL,
          SurveyDefinition.class);

      query.setParameter("id", id);
      query.setParameter("version", version);

      List<SurveyDefinition> surveyDefinitions = query.getResultList();

      if (surveyDefinitions.size() == 0)
      {
        return null;
      }
      else
      {
        return surveyDefinitions.get(0);
      }
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to retrieve the survey definition (" + id + ")", e);
    }
  }

  /**
   * Save the survey definition.
   *
   * @param surveyDefinition the survey definition
   *
   * @return the saved survey definition
   */
  @Transactional
  public SurveyDefinition saveSurveyDefinition(SurveyDefinition surveyDefinition)
    throws SurveyServiceException
  {
    try
    {
      // Check if a survey instance exists for the current version of the survey definition
      Query surveyInstanceExistsQuery = entityManager.createQuery(
          "SELECT COUNT(si.id) FROM SurveyInstance si JOIN si.surveyDefinition sd"
          + " WHERE sd.id = :id AND sd.version = :version");

      surveyInstanceExistsQuery.setParameter("id", surveyDefinition.getId());
      surveyInstanceExistsQuery.setParameter("version", surveyDefinition.getVersion());

      boolean surveyInstanceExists =
          (((Number) surveyInstanceExistsQuery.getSingleResult()).intValue() > 0);

      // Duplicate the survey definition and increment the current version if required
      if (surveyInstanceExists)
      {
        surveyDefinition = surveyDefinition.duplicate();

        surveyDefinition.incrementVersion();
      }

      if (!entityManager.contains(surveyDefinition))
      {
        surveyDefinition = entityManager.merge(surveyDefinition);
      }

      return surveyDefinition;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey definition with ID ("
          + surveyDefinition.getId() + ")", e);
    }
  }

  /**
   * Save the survey instance.
   *
   * @param surveyInstance the survey instance
   *
   * @return the saved survey instance
   */
  @Transactional
  public SurveyInstance saveSurveyInstance(SurveyInstance surveyInstance)
    throws SurveyServiceException
  {
    try
    {
      if (!entityManager.contains(surveyInstance))
      {
        surveyInstance = entityManager.merge(surveyInstance);
      }

      return surveyInstance;
    }
    catch (Throwable e)
    {
      throw new SurveyServiceException("Failed to save the survey instance with ID ("
          + surveyInstance.getId() + ")", e);
    }
  }
}
